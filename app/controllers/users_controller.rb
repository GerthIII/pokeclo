class UsersController < ApplicationController

  def dashboard
    @items = policy_scope(Item)
    @outfits = policy_scope(Outfit)

    # authorize the models presents and calling the dashboard function to check if the user is logged
    authorize Item, :dashboard?
    authorize Outfit, :dashboard?
  end
end
