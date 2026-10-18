class ItemsController < ApplicationController
  def index
    @items = policy_scope(Item)
    @owned_items = @items.owned
    @not_bought_items = @items.wishlist
  end

  def new
    @item = Item.new
    authorize @item
  end

  def create
    @item = Item.new(item_params.except(:photo))
    @item.user = current_user
    authorize @item

    if params[:item][:photo].present?
      processed = BackgroundRemoverService.call(params[:item][:photo])
      @item.photo.attach(processed)
    end

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
    # DECISION: Look items up inside the current user's closet only.
    #   Chose: policy_scope(...).find, so another user's item is a 404 (does not reveal it exists).
    #   Rejected: Item.find + 403 (confirms the ID is real; one forgotten authorize leaks data).
    @item = policy_scope(Item).find(params[:id])
    authorize @item
  end

  def edit
    @item = policy_scope(Item).find(params[:id])
    authorize @item
  end

  def update
    @item = policy_scope(Item).find(params[:id])
    authorize @item

    if @item.update(item_params)
      redirect_to item_path(@item)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_as_bought
    @item = policy_scope(Item).find(params[:id])
    authorize @item, :update?

    if @item.update(status: :owned)
      if ActiveModel::Type::Boolean.new.cast(params[:create_outfit_with_ai])
        outfit = current_user.outfits.create!(status: :draft, name: "Add a Name To Your Outfit")
        authorize outfit
        outfit.outfit_items.create!(item: @item, slot: @item.slot)
        redirect_to edit_outfit_path(outfit, auto_ask: true)
        return
      end

      respond_to do |format|
        format.html { redirect_to item_path(@item) }
        format.json { render json: { id: @item.id, status: @item.status }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to item_path(@item) }
        format.json { render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # This action analyzes the photo provided during new item creation.
  def analyze_photo
    authorize Item
    photo = BackgroundRemoverService.call(params[:photo])
    result = ItemAnalyzerService.call(photo)
    render json: result
  # DECISION: Log the real error; send the browser a generic message (internal details can leak secrets or stack info).
  rescue StandardError => e
    Rails.logger.error("Photo analysis failed: #{e.class} - #{e.message}")
    render json: { error: "Could not analyze photo" }, status: :unprocessable_entity
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :photo, :category, :slot, :status, :commit_action)
  end
end
