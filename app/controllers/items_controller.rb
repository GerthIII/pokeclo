class ItemsController < ApplicationController

  def index

  end

  def show
    @item = Item.find(params[:item_id])
  end
private
  def item_params
    params.require(:item).permit(:name, :category, :description, :slot)
  end
end
