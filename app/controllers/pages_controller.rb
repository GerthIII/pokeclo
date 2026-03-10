class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]
  # Makes the Home visible in the scope of the pundit
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def home
    @item = Item.new
  end

end
