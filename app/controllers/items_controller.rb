class ItemsController < ApplicationController
  def index
  @items = Item.all
  end
  def new
    @items = Item.new
  end
  def create
  end
end
