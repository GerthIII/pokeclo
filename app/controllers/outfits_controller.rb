class OutfitsController < ApplicationController
  # DECISION: Try-on costs money per call. POST only, at most 2 attempts, and only on network/API errors.
  #   Rejected: background job (better, but a much bigger change for now); sleep between retries (blocks a web thread).
  TRY_ON_ATTEMPTS = 2
  # Same errors ruby_llm treats as transient. Not RubyLLM::Error as a whole: it includes
  # BadRequest/Unauthorized/PaymentRequired/Forbidden, which never succeed on retry.
  RETRYABLE_AI_ERRORS = [
    RubyLLM::RateLimitError, RubyLLM::ServerError, RubyLLM::ServiceUnavailableError, RubyLLM::OverloadedError,
    Faraday::TimeoutError, Faraday::ConnectionFailed
  ].freeze
  SLOT_PARAMS = %i[top_item_id bottom_item_id outer_item_id footwear_item_id].freeze

  def index
    @outfits = policy_scope(Outfit)
  end

  # DECISION: Same as ItemsController: policy_scope(...).find, so other users' outfits are a 404.
  def show
    @outfit = policy_scope(Outfit).find(params[:id])
    authorize @outfit
    @pending_purchase_items = @outfit.items.wishlist
  end

  def new
    load_slot_items
    @auto_ask = params[:auto_ask].present?
    return create_draft_outfit if params[:outfit_id].blank?

    @outfit = current_user.outfits.find(params[:outfit_id])
    authorize @outfit
    @messages = @outfit.messages
    @message = Message.new
    prepare_outfit_form
  end

  def create
    @outfit = draft_or_new_outfit
    authorize @outfit
    assign_slot_item_ids
    if save_outfit_with_items
      redirect_after_save(new_outfit_path(outfit_id: @outfit.id, auto_ask: true))
    else
      render_invalid(:new)
    end
  end

  def edit
    @outfit = current_user.outfits.find(params[:id])
    # authorizes the outfit with Pundit
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
    @outfit = current_user.outfits.find(params[:id])
    authorize @outfit
    assign_slot_item_ids
    if save_outfit_with_items
      redirect_after_save(edit_outfit_path(@outfit, auto_ask: true))
    else
      render_invalid(:edit)
    end
  end

  def try_on
    @outfit = policy_scope(Outfit).find(params[:id])
    authorize @outfit, :try_on?
    return no_profile_photo unless current_user.profile_photo.attached?

    if attach_try_on_image
      redirect_to outfit_path(@outfit), status: :see_other
    else
      redirect_to outfit_path(@outfit), alert: "OOPS, something went wrong. Please try again.", status: :see_other
    end
  end

  private

  def no_profile_photo
    redirect_to edit_user_registration_path, alert: "Add a profile photo to try outfits on.", status: :see_other
  end

  def create_draft_outfit
    @outfit = current_user.outfits.create!(status: :draft, name: "Add a Name To Your Outfit")
    if params[:item_id]
      @item = current_user.items.find(params[:item_id])
      OutfitItem.create!(item: @item, outfit: @outfit, slot: @item.slot)
    end
    authorize @outfit
    redirect_to new_outfit_path(outfit_id: @outfit.id, item_id: params[:item_id], auto_ask: params[:auto_ask])
  end

  def prepare_outfit_form
    @outfit.normalize_outfit_item_slots!
    hydrate_slot_item_ids(@outfit)
    build_ai_slot_metadata(@outfit)
    prefill_from_item_param
  end

  # assign virtual attrs so validation can read them
  def assign_slot_item_ids
    SLOT_PARAMS.each { |param| @outfit.public_send("#{param}=", outfit_params[param]) }
  end

  def redirect_after_save(advice_path)
    if params[:ask_for_advice]
      redirect_to advice_path
    elsif params[:redirect_to_edit]
      redirect_to edit_outfit_path(@outfit)
    else
      redirect_to outfit_path(@outfit)
    end
  end

  def draft_or_new_outfit
    # If this came from a draft, update it instead of creating a new one.
    return current_user.outfits.find(params[:outfit_id]) if params[:outfit_id].present?

    Outfit.new(outfit_params.except(*SLOT_PARAMS).merge(user: current_user))
  end

  def save_outfit_with_items
    # DECISION: Save outfit + its items all-or-nothing so a failure can't leave a half-empty outfit.
    Outfit.transaction do
      raise ActiveRecord::Rollback unless @outfit.update(outfit_params.except(*SLOT_PARAMS))

      @outfit.outfit_items.destroy_all
      create_outfit_items(@outfit)
      true
    end || false
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.full_messages.each { |message| @outfit.errors.add(:base, message) }
    false
  end

  def render_invalid(template)
    load_slot_items
    @auto_ask = params[:auto_ask].present?
    @messages = @outfit.messages
    @message = Message.new
    build_ai_slot_metadata(@outfit)
    render template, status: :unprocessable_entity
  end

  def attach_try_on_image(attempt = 1)
    generate_try_on_photo
    true
  rescue *RETRYABLE_AI_ERRORS => e
    return attach_try_on_image(attempt + 1) if attempt < TRY_ON_ATTEMPTS

    log_try_on_failure(e)
  rescue StandardError => e
    log_try_on_failure(e)
  end

  def log_try_on_failure(error)
    Rails.logger.error("Try-on generation failed: #{error.class} - #{error.message}")
    nil
  end

  def generate_try_on_photo
    result = GeminiService.generate_try_on(base: current_user.profile_photo, items: @outfit.items.map(&:photo))
    @outfit.photo.attach(io: result, filename: "#{@outfit.id}.png", content_type: "image/png")
  end

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
    outfit.outfit_items.create!(item_id: outfit.top_item_id, slot: "top") if outfit.top_item_id.present?
    outfit.outfit_items.create!(item_id: outfit.bottom_item_id, slot: "bottom") if outfit.bottom_item_id.present?
    outfit.outfit_items.create!(item_id: outfit.outer_item_id, slot: "outer") if outfit.outer_item_id.present?
    outfit.outfit_items.create!(item_id: outfit.footwear_item_id, slot: "footwear") if outfit.footwear_item_id.present?
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
