class Admin::UsersController < ApplicationController
  authorize_resource
  before_action :set_user, only: [:show, :edit, :update, :destroy, :avatar]
  helper UsersHelper

  # GET /admin/users
  def index
    roles = []
    roles += ['admin'] if params[:search_admins] === 'on'
    roles += ['student'] if params[:search_students] === 'on'
    roles += ['teacher'] if params[:search_teachers] === 'on'
    roles += ['worker'] if params[:search_workers] === 'on'

    users = if !params[:q].nil?
      params[:search_by] = 'login' unless ['login', 'email', 'full_name'].include?(params[:search_by])
      params[:q] ||= ''

      params[:search_admins] ||= 'off'
      params[:search_students] ||= 'off'
      params[:search_teachers] ||= 'off'
      params[:search_workers] ||= 'off'

      User.with_matched_field_and_role(params[:search_by], params[:q], roles)
    else
      User.all
    end

    params[:search_by] ||= 'login'
    @users = users.page(params[:page])
  end

  # GET /admin/users/1
  def show
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # GET /admin/users/1/edit
  def edit
  end

  # POST /admin/users
  def create
    @user = User.new(user_params)
    @user.roles = user_params[:role] || []

    if @user.save
      redirect_to [:admin, @user], notice: t('users.notice.created')
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/users/1
  def update
    @user.roles = user_params[:role] || []

    if @user.update(user_params.except(:role))
      redirect_to [:admin, @user], notice: t('users.notice.updated')
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/users/1
  def destroy
    @user.avatar.destroy
    @user.destroy
    redirect_to admin_users_url
  end

  def avatar
    if @user.avatar.destroy
      @user.save
      redirect_to edit_admin_user_path(@user)
    else
      redirect_to edit_admin_user_path(@user), :alert => t('activerecord.errors.models.avatar.delete')
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user)
       .permit(:login, :password, :password_confirmation, { :role => [] }, :email, :full_name, :avatar)
       .delete_if {|k, v| k =~ /password/ && v.blank?}
  end
end
