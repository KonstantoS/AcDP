class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t('util.access_denied')
    redirect_to root_path
  end

  # By default it should be done with 
  # comment_destroy_conditions. But Opinio does not 
  # support Rails 4, so this method replace that helper
	def can_destroy_opinio?(comment)
		comment.owner == current_user
	end
end
