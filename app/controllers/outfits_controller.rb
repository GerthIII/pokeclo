class OutfitsController < ApplicationController
  TRY_ON_FAILED = "OOPS, something went wrong. Please try again.".freeze

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
    return create_draft_outfit if params[:outfit_id].blank?

    @outfit = current_user.outfits.find(params[:outfit_id])
    authorize @outfit
    prepare_outfit_form
  end

  def create
    @outfit = draft_or_new_outfit
    authorize @outfit
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
    @outfit.hydrate_slot_item_ids!
    load_form_state
  end

  def update
    @outfit = current_user.outfits.find(params[:id])
    authorize @outfit
    if save_outfit_with_items
      redirect_after_save(edit_outfit_path(@outfit, auto_ask: true))
    else
      render_invalid(:edit)
    end
  end

  def destroy
    @outfit = policy_scope(Outfit).find(params[:id])
    authorize @outfit
    @outfit.destroy
    redirect_to outfits_path, status: :see_other, notice: "Outfit deleted."
  end

  def try_on
    @outfit = policy_scope(Outfit).find(params[:id])
    authorize @outfit, :try_on?
    return no_profile_photo unless current_user.profile_photo.attached?

    failed = !TryOnGenerator.new(outfit: @outfit, user: current_user).call
    redirect_to outfit_path(@outfit), status: :see_other, alert: (TRY_ON_FAILED if failed)
  end

  private

  def no_profile_photo
    redirect_to edit_user_registration_path, alert: "Add a profile photo to try outfits on.", status: :see_other
  end

  def create_draft_outfit
    @outfit = current_user.outfits.create!(status: :draft, name: "Add a Name To Your Outfit")
    @outfit.add_item!(current_user.items.find(params[:item_id])) if params[:item_id]
    authorize @outfit
    redirect_to new_outfit_path(outfit_id: @outfit.id, item_id: params[:item_id], auto_ask: params[:auto_ask])
  end

  def prepare_outfit_form
    @outfit.normalize_outfit_item_slots!
    @outfit.hydrate_slot_item_ids!
    load_form_state
    prefill_from_item_param
  end

  def redirect_after_save(advice_path)
    return redirect_to advice_path if params[:ask_for_advice]

    redirect_to(params[:redirect_to_edit] ? edit_outfit_path(@outfit) : outfit_path(@outfit))
  end

  def draft_or_new_outfit
    # If this came from a draft, update it instead of creating a new one.
    return current_user.outfits.find(params[:outfit_id]) if params[:outfit_id].present?

    Outfit.new(outfit_params.except(*Outfit::SLOT_ITEM_ATTRS).merge(user: current_user))
  end

  def save_outfit_with_items
    @outfit.save_with_slot_items(outfit_params)
  end

  def render_invalid(template)
    load_form_state
    render template, status: :unprocessable_entity
  end

  def outfit_params
    params.require(:outfit).permit(:name, :description, :status, *Outfit::SLOT_ITEM_ATTRS)
  end

  def load_form_state
    @tops, @bottoms, @footwear, @outers =
      %w[top bottom footwear outer].map { |slot| current_user.items.where(slot: slot) }
    @auto_ask = params[:auto_ask].present?
    @messages = @outfit.messages
    @message = Message.new
    @latest_suggestion_message, @suggested_slot_item_ids = @outfit.latest_suggestion
  end

  def prefill_from_item_param
    item = current_user.items.find_by(id: params[:item_id]) if params[:item_id].present?
    @outfit.assign_slot_item(item) if item
  end
end
