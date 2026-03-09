class ItemsController < ApplicationController
  def index
    @items = Item.all
  end

  def new
    @item = Item.new
    raise
  end

  def create
    @item = Item.new(item_params)
    @item.user = current_user

    if @item.save
      redirect_to items_path(@item)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @item = Item.find(params[:id])
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])

    if @item.update(item_params)
      redirect_to item_path(@item), notice: "Item updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def capture_photo
    item = current_user.items.create(
      name: "name",
      description: "description",
      category: "category",
      slot: "top",
    )
    item.photo.attach(params[:item][:photo])
    redirect_to edit_item_path(item)
  end

  # ✅ ここに独立して書く
  def add_to_outfit
    item = Item.find(params[:id])
    outfit = current_user.outfits.order(created_at: :desc).first

    if outfit.present?
      outfit.jackets.attach(item.photo.blob)
      redirect_to edit_outfit_path(outfit), notice: "Added to outfit!"
    else
      redirect_to new_outfit_path, alert: "Create an outfit first!"
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :photo, :category, :slot)
  end
end
