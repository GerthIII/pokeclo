class UsersController < ApplicationController

  def dashboard
    @items = Item.all
    @outfits = Outfit.all
  end
end
