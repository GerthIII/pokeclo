class OutfitsController < ApplicationController
  def index
    @outfits = policy_scope(Outfit)
  end

  def show
    @outfit = Outfit.find(params[:id])
    # authorizes user to crate an item with Pundit
    authorize @outfit
    @pending_purchase_items = @outfit.items.where(status: 2)
  end

  def new
    load_slot_items
    @auto_ask = params[:auto_ask].present?

    if params[:outfit_id].present?
      @outfit = current_user.outfits.find(params[:outfit_id])
      @messages = @outfit.messages
      @message = Message.new
      authorize @outfit
      @outfit.normalize_outfit_item_slots!
      hydrate_slot_item_ids(@outfit)
      build_ai_slot_metadata(@outfit)
      prefill_from_item_param
    else
      @outfit = Outfit.create!(user: current_user, status: "draft", name: "Draft")
      if params[:item_id]
        @item = current_user.items.find(params[:item_id])
        OutfitItem.create!(item: @item, outfit: @outfit, slot: @item.slot)
      end
      authorize @outfit
      redirect_to new_outfit_path(outfit_id: @outfit.id, item_id: params[:item_id], auto_ask: params[:auto_ask])
      return
    end

    # authorizes user to crate an item with Pundit
    authorize @outfit
    prefill_from_item_param
  end

  def create
    load_slot_items

    # Se veio de um draft, atualiza ele em vez de criar novo
    if params[:outfit_id].present?
      @outfit = current_user.outfits.find(params[:outfit_id])
      authorize @outfit
    else
      @outfit = Outfit.new(outfit_params.except(:top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id))
      @outfit.user = current_user
      authorize @outfit
    end

    @outfit.top_item_id      = outfit_params[:top_item_id]
    @outfit.bottom_item_id   = outfit_params[:bottom_item_id]
    @outfit.outer_item_id    = outfit_params[:outer_item_id]
    @outfit.footwear_item_id = outfit_params[:footwear_item_id]

    if @outfit.update(outfit_params.except(:top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id))
      @outfit.outfit_items.destroy_all
      create_outfit_items(@outfit)
      if params[:ask_for_advice]
        redirect_to new_outfit_path(outfit_id: @outfit.id, auto_ask: true)
      elsif params[:redirect_to_edit]
        redirect_to edit_outfit_path(@outfit)
      else
        redirect_to outfit_path(@outfit), notice: "Outfit created!"
      end
    else
      @messages = @outfit.messages
      @message = Message.new
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @outfit = current_user.outfits.find(params[:id])
    # authorizes user to crate an item with Pundit
    authorize @outfit
    @outfit.normalize_outfit_item_slots!
    @auto_ask = params[:auto_ask].present?
    hydrate_slot_item_ids(@outfit)
    load_slot_items
    @messages = @outfit.messages
    @message = Message.new
    build_ai_slot_metadata(@outfit)
  end

  def update
    @outfit = current_user.outfits.find(params[:id])#v.except(:top_item_id, :bottom_item_id, :outer_item_id,
  #:footwear_item_id))
    @outfit.user = current_user
    # authorizes user to crate an item with Pundit
    authorize @outfit
    # assign virtual attrs so validation can read them
    @outfit.top_item_id    = outfit_params[:top_item_id]
    @outfit.bottom_item_id = outfit_params[:bottom_item_id]
    @outfit.outer_item_id  = outfit_params[:outer_item_id]
    @outfit.footwear_item_id = outfit_params[:footwear_item_id]

    if @outfit.update(outfit_params.except(:top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id))
      @outfit.outfit_items.destroy_all
      create_outfit_items(@outfit)
      if params[:ask_for_advice]
        redirect_to edit_outfit_path(@outfit, auto_ask: true)
      elsif params[:redirect_to_edit]
        redirect_to edit_outfit_path(@outfit)
      else
        redirect_to outfit_path(@outfit), notice: "Outfit updated!"
      end
    else
      @messages = @outfit.messages
      @message = Message.new
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

  def try_on
    @outfit = Outfit.find(params[:id])
    authorize @outfit, :try_on?
    if current_user.profile_photo.attached?
      result_image = GeminiService.generate_try_on(
        base: current_user.profile_photo,
        items: @outfit.items.map(&:photo)
      )
      @outfit.photo.attach(io: result_image, filename: "#{@outfit.id}.png", content_type: "image/png")
      redirect_to outfit_path(@outfit), notice: "Virtual try_on complete!"
    else
      redirect_to edit_user_registration_path, alert: "Please upload a full-body photo first"
    end
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
    outfit.outfit_items.create(item_id: outfit.top_item_id, slot: "top") if outfit.top_item_id.present?
    outfit.outfit_items.create(item_id: outfit.bottom_item_id, slot: "bottom") if outfit.bottom_item_id.present?
    outfit.outfit_items.create(item_id: outfit.outer_item_id, slot: "outer") if outfit.outer_item_id.present?
    outfit.outfit_items.create(item_id: outfit.footwear_item_id, slot: "footwear") if outfit.footwear_item_id.present?
  end

  def hydrate_slot_item_ids(outfit)
    slot_item_ids = outfit.outfit_items.pluck(:slot, :item_id).to_h
    outfit.top_item_id = slot_item_ids["top"]
    outfit.bottom_item_id = slot_item_ids["bottom"]
    outfit.outer_item_id = slot_item_ids["outer"]
    outfit.footwear_item_id = slot_item_ids["footwear"]
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

  def user_params
    params.require(:user).permit(:name, :email, :profile_photo)
  end

  def build_ai_slot_metadata(outfit)
    @latest_suggestion_message = nil
    @suggested_slot_item_ids = {}

    outfit.messages.where(role: "assistant").order(created_at: :desc).each do |message|
      parsed = JSON.parse(message.content)
      next unless parsed.is_a?(Array)

      slot_item_ids = {}
      parsed.each do |entry|
        next unless entry.is_a?(Hash)
        slot = entry["slot"].to_s
        item_id = entry["item_id"].to_i
        next if slot.blank? || item_id.zero?
        slot_item_ids[slot] = item_id
      end
      next if slot_item_ids.empty?

      @latest_suggestion_message = message
      @suggested_slot_item_ids = slot_item_ids
      break
    rescue JSON::ParserError
      next
    end
  end
end
