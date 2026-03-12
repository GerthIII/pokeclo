class ItemsController < ApplicationController
  def index
    @items = policy_scope(Item)
    @owned_items = @items.where(status: 1)
    @not_bought_items = @items.where(status: 2)
  end

  def new
    @item = Item.new
    # authorizes user to crate an item with Pundit
    authorize @item
  end

  def create
    # @item = Item.new(item_params.except(:photo))
    @item = Item.new(item_params)
    @item.user = current_user
    # authorizes user to crate an item with Pundit
    authorize @item

    # if params[:item][:photo].present?
    #   # processed = BackgroundRemoverService.call(params[:item][:photo])
    #   @item.photo.attach(params[:item][:photo])
    # end

    if @item.save
      if params[:commit_action] == "Create Outfit"
        redirect_to new_outfit_path(item_id: @item.id, auto_ask: true)
      else
        redirect_to item_path(@item)
      end
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
      redirect_to item_path(@item)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_as_bought
    @item = Item.find(params[:id])
    authorize @item, :update?

    if @item.update(status: 1)
      if ActiveModel::Type::Boolean.new.cast(params[:create_outfit_with_ai])
        outfit = Outfit.create!(user: current_user, status: "draft", name: "Add a Name To Your Outfit")
        authorize outfit
        outfit.outfit_items.create!(item: @item, slot: @item.slot)
        redirect_to edit_outfit_path(outfit, auto_ask: true),
                    notice: "Item marked as bought! Creating outfit suggestions..."
        return
      end

      respond_to do |format|
        format.html { redirect_to item_path(@item), notice: "Item marked as bought!" }
        format.json { render json: { id: @item.id, status: @item.status }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to item_path(@item), alert: "Could not update item status." }
        format.json { render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def capture_photo
    # photo = BackgroundRemoverService.call(params[:item][:photo])
    photo = params[:item][:photo]
    result = ItemAnalyzerService.call(photo)
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
      redirect_to edit_outfit_path(outfit)
    else
      redirect_to new_outfit_path
    end
  end

  # This action analyzes the photo provided during new item creation.
  def analyze_photo
    authorize Item
    # photo = BackgroundRemoverService.call(params[:photo])
    photo = params[:photo]
    result = ItemAnalyzerService.call(photo)
    render json: result
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :photo, :category, :slot, :status, :commit_action)
  end
end
