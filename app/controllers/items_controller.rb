class ItemsController < ApplicationController
  # Runs before the paid photo calls. authorize comes first so Pundit's verify_authorized is satisfied on redirect.
  before_action :redirect_if_limit_reached, only: %i[new create]

  def index
    @items = policy_scope(Item)
    @items_total = @items.count
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

    attach_processed_photo
    if @item.save
      redirect_to after_create_path
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
    @outfit_count = @item.outfits.distinct.count
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

  # DECISION: Deleting an item removes it from the outfits that use it (the slot goes empty, the outfits stay).
  #   The confirm dialog shows how many outfits use it. The outfits' try-on photos are kept (they were paid for).
  #   Rejected: blocking the delete while used (the user must edit every outfit first).
  #   Rejected: deleting those outfits too (one click could wipe many outfits and chats).
  def destroy
    @item = policy_scope(Item).find(params[:id])
    authorize @item
    @item.destroy
    redirect_to items_path, status: :see_other, notice: "Item deleted."
  end

  # DECISION: Mark as bought only moves the item from the wishlist to the closet.
  #   Rejected: also creating a draft outfit (the old button did, then 500'd on a missing policy method).
  def mark_as_bought
    @item = policy_scope(Item).find(params[:id])
    authorize @item, :update?
    return render_not_bought unless @item.update(status: :owned)

    respond_to do |format|
      format.html { redirect_to item_path(@item), status: :see_other }
      format.json { render json: { id: @item.id, status: @item.status }, status: :ok }
    end
  end

  # This action analyzes the photo provided during new item creation.
  def analyze_photo
    authorize Item
    if Item.limit_reached_for?(current_user)
      return render json: { error: Item.limit_message }, status: :unprocessable_entity
    end

    photo = BackgroundRemoverService.call(params[:photo])
    result = ItemAnalyzerService.call(photo)
    render json: result
  # DECISION: Log the real error; send the browser a generic message (internal details can leak secrets or stack info).
  rescue StandardError => e
    Rails.logger.error("Photo analysis failed: #{e.class} - #{e.message}")
    render json: { error: "Could not analyze photo" }, status: :unprocessable_entity
  end

  private

  def redirect_if_limit_reached
    authorize Item
    redirect_to items_path, alert: Item.limit_message if Item.limit_reached_for?(current_user)
  end

  def attach_processed_photo
    return if params[:item][:photo].blank?

    @item.photo.attach(BackgroundRemoverService.call(params[:item][:photo]))
  end

  def after_create_path
    if params[:commit_action] == "Create Outfit"
      new_outfit_path(item_id: @item.id, auto_ask: true)
    else
      item_path(@item)
    end
  end

  def render_not_bought
    respond_to do |format|
      format.html { redirect_to item_path(@item) }
      format.json { render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity }
    end
  end

  def item_params
    params.require(:item).permit(:name, :description, :photo, :category, :slot, :status, :commit_action)
  end
end
