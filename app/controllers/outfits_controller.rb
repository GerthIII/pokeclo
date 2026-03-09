class OutfitsController < ApplicationController
  def index
    @outfits = policy_scope(Outfit)
  end

  def show
    @outfit = Outfit.find(params[:id])
    # authorizes user to crate an item with Pundit
    authorize @outfit
  end

  def new
    load_slot_items
    @outfit = Outfit.new
    # authorizes user to crate an item with Pundit
    authorize @outfit
    prefill_from_item_param
  end

  def create
    load_slot_items
    @outfit = Outfit.new(outfit_params.except(:top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id))
    @outfit.user = current_user
    # authorizes user to crate an item with Pundit
    authorize @outfit
    # assign virtual attrs so validation can read them
    @outfit.top_item_id    = outfit_params[:top_item_id]
    @outfit.bottom_item_id = outfit_params[:bottom_item_id]
    @outfit.outer_item_id  = outfit_params[:outer_item_id]
    @outfit.footwear_item_id = outfit_params[:footwear_item_id]
    if @outfit.save
      create_outfit_items(@outfit)
      if params[:open_in_new].present?
        redirect_to new_outfit_path(outfit_id: @outfit.id), notice: "Outfit draft created!"
      else
        redirect_to outfit_path(@outfit), notice: "Outfit created!"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @outfit = current_user.outfits.find(params[:id])
    # authorizes user to crate an item with Pundit
    authorize @outfit
    load_slot_items
  end

  def update
    @outfit = current_user.outfits.find(params[:id])#.except(:top_item_id, :bottom_item_id, :outer_item_id,
                                                           #:footwear_item_id))
    @outfit.user = current_user
    # authorizes user to crate an item with Pundit
    authorize @outfit
    # assign virtual attrs so validation can read them
    @outfit.top_item_id    = outfit_params[:top_item_id]
    @outfit.bottom_item_id = outfit_params[:bottom_item_id]
    @outfit.outer_item_id  = outfit_params[:outer_item_id]
    @outfit.footwear_item_id = outfit_params[:footwear_item_id]

    if @outfit.update(outfit_params)
      redirect_to outfit_path(@outfit), notice: "Outfit updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def chat
    @outfit = Outfit.find(params[:id])
    authorize @outfit
    @messages = @outfit.messages
    authorize @messages
    @message = Message.new
    authorize @message
  end

  private

  def outfit_params
    params.require(:outfit).permit(
      :name,
      :description,
      :status,
      :top_item_id,
      :bottom_item_id,
      :outer_item_id,
      :footwear_item_id
    )
  end

  def load_slot_items
    @tops = current_user.items.where(slot: "top")
    @bottoms = current_user.items.where(slot: "bottom")
    @footwear = current_user.items.where(slot: "footwear")
    @outers = current_user.items.where(slot: "outer")
  end

  def create_outfit_items(outfit)
    outfit.outfit_items.create(item_id: outfit.top_item_id) if outfit.top_item_id.present?
    outfit.outfit_items.create(item_id: outfit.bottom_item_id) if outfit.bottom_item_id.present?
    outfit.outfit_items.create(item_id: outfit.outer_item_id) if outfit.outer_item_id.present?
    outfit.outfit_items.create(item_id: outfit.footwear_item_id) if outfit.footwear_item_id.present?
  end

  def prefill_from_item_param
    return if params[:item_id].blank?

    item = current_user.items.find_by(id: params[:item_id])
    return unless item

    case item.slot
    when "top"   then @outfit.top_item_id = item.id
    when "bottom"then @outfit.bottom_item_id = item.id
    when "outer" then @outfit.outer_item_id = item.id
    when "footwear" then @outfit.footwear_item_id = item.id
    end
  end
end
