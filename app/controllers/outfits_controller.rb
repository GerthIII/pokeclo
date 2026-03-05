class OutfitsController < ApplicationController
  def index
    @outfits = Outfit.all
  end

  def show
    @outfit = Outfit.find(params[:id])
  end

  def new
    @outfit = Outfit.new
    load_slot_items
  end

  def create
    @outfit = Outfit.new(outfit_params.except(:top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id))
    @outfit.user = current_user
    # assign virtual attrs so validation can read them
    @outfit.top_item_id    = outfit_params[:top_item_id]
    @outfit.bottom_item_id = outfit_params[:bottom_item_id]
    @outfit.outer_item_id  = outfit_params[:outer_item_id]
    @outfit.footwear_item_id = outfit_params[:footwear_item_id]

    if @outfit.save
      create_outfit_items(@outfit)
      redirect_to outfit_path(@outfit), notice: "Outfit created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @outfit = current_user.outfits.find(params[:id])
  end

  def update
    @outfit = current_user.outfits.find(params[:id])

    if @outfit.update(outfit_params)
      redirect_to outfit_path(@outfit), notice: "Outfit updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def chat
    @outfit = Outfit.find(params[:id])
    @messages = @outfit.messages
    @message = Message.new
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
end
