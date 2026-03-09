class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization

# Thi line will make the home visible even with pundit
after_action :verify_policy_scoped, if: -> { action_name == "index" && !skip_pundit? }
after_action :verify_authorized,   if: -> { action_name != "index" && !skip_pundit? }


   def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_up_path_for(resource)
    dashboard_path
  end

 def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

end
