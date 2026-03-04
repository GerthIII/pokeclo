class UsersController < ApplicationController

  def dashboard
    @items = Item.all
  end
end
