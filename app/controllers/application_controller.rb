class ApplicationController < ActionController::Base
  before_action :authenticate_user!

<<<<<<< HEAD
=======
   def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_up_path_for(resource)
    dashboard_path
  end
>>>>>>> master

end
