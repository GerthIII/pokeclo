class ItemsController < ApplicationController
  def index
    @items = policy_scope(Item)
    @item_filtered = @items.where(params[:slot])
  end

  def new
    @item = Item.new
    # authorizes user to crate an item with Pundit
    authorize @item
  end

  def create
    @item = Item.new(item_params)
    @item.user = current_user
    # authorizes user to crate an item with Pundit
    authorize @item

    if @item.save
      redirect_to item_path(@item)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @item = Item.find(params[:id])
    # this will authorize all of the items to be seen
  authorize @item
  end

  def edit
    @item = Item.find(params[:id])
    # authorizes user to crate an item with Pundit
    authorize @item
  end

  def update
    @item = Item.find(params[:id])
    # authorizes user to crate an item with Pundit
    authorize @item

    if @item.update(item_params)
      redirect_to item_path(@item), notice: "Item updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def capture_photo
    result = ItemAnalyzerService.call(params[:item][:photo])
    item = current_user.items.create(
      name: result["name"],
      description: result["description"],
      category: result["category"],
      slot: result["slot"]
    )
    authorize item
    item.photo.attach(params[:item][:photo])
    redirect_to edit_item_path(item)
  end

  # ✅ ここに独立して書く
  def add_to_outfit
    item = Item.find(params[:id])
    outfit = current_user.outfits.order(created_at: :desc).first
    # authorizes user to crate an item with Pundit
    authorize @item

    if outfit.present?
      outfit.jackets.attach(item.photo.blob)
      redirect_to edit_outfit_path(outfit), notice: "Added to outfit!"
    else
      redirect_to new_outfit_path, alert: "Create an outfit first!"
    end
  end

  # This action analyzes the photo provided during new item creation.
  def analyze_photo
    authorize Item
    photo = params[:photo]
    result = ItemAnalyzerService.call(photo)
    render json: result
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :photo, :category, :slot)
  end
end
