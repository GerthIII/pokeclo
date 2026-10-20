class MessagesController < ApplicationController
  # DECISION: The LLM sometimes replies with non-JSON. Retry up to 3 total attempts, then show one error.
  #   Rejected: 5 attempts (slow + costly during an outage); no retry (users see avoidable failures).
  AI_ATTEMPTS = 3

  # DECISION: Load the outfit once, scoped to the current user, for every action.
  #   Chose: before_action, so new actions are protected by default.
  #   Rejected: Outfit.find in each action (that's how the original cross-user hole happened).
  before_action :set_outfit

  def create
    @message = @outfit.messages.build(message_params)
    authorize @message
    @message.role = "user"
    return redirect_to redirect_path_for_outfit(@outfit), alert: "Message can't be blank." unless @message.save

    finish_chat(fetch_suggestions)
  end

  def confirm
    @message = @outfit.messages.find(params[:id])
    authorize @message
    @outfit.apply_suggestions!(JSON.parse(@message.content))
    redirect_to edit_outfit_path(@outfit)
  rescue JSON::ParserError
    redirect_to edit_outfit_path(@outfit)
  end

  def change_slot
    @message = @outfit.messages.find(params[:id])
    authorize @message, :confirm?
    return redirect_to edit_outfit_path(@outfit) unless prepare_slot_change

    regenerate_slot
  end

  private

  def set_outfit
    @outfit = policy_scope(Outfit).find(params[:outfit_id])
  end

  def finish_chat(suggestions)
    if suggestions
      replace_assistant_message(suggestions)
      @outfit.apply_suggestions!(suggestions)
      redirect_to redirect_path_for_outfit(@outfit)
    else
      replace_assistant_message("Sorry, try again.")
      redirect_to outfit_path(@outfit), alert: "OOPS, something went wrong. Please try again!"
    end
  end

  # Returns the parsed suggestions Array, or nil after AI_ATTEMPTS bad replies. Saves nothing.
  def fetch_suggestions
    AI_ATTEMPTS.times do
      parsed = JSON.parse(stylist_reply.content)
      return parsed if parsed.is_a?(Array)
    rescue JSON::ParserError
      next
    end
    nil
  end

  def stylist_reply
    StylistChat.new(outfit: @outfit, message: @message,
                    candidate_slots: @forced_candidate_slots, excluded_item_ids: @excluded_item_ids || []).ask
  end

  def replace_assistant_message(content)
    @outfit.messages.where(role: "assistant").destroy_all
    @outfit.messages.create!(role: "assistant", content: content.is_a?(String) ? content : content.to_json)
  end

  def prepare_slot_change
    slot = params[:slot].to_s
    return false unless Outfit::SLOTS.include?(slot)

    current_item_id = params[:current_item_id].presence&.to_i
    candidates = current_user.items.where(slot: slot)
    candidates = candidates.where.not(id: current_item_id) if current_item_id.present?
    return false if candidates.none?

    @forced_candidate_slots = [slot]
    @excluded_item_ids = [current_item_id].compact
  end

  def regenerate_slot
    user_message = @outfit.messages.build(role: "user", content: slot_change_prompt)
    return redirect_to(redirect_path_for_outfit(@outfit)) unless user_message.save

    @message = user_message
    save_slot_reply(fetch_suggestions)
    redirect_to redirect_path_for_outfit(@outfit)
  end

  def save_slot_reply(suggestions)
    if suggestions
      @outfit.messages.create!(role: "assistant", content: suggestions.to_json)
      @outfit.apply_suggestions!(suggestions)
    else
      @outfit.messages.create!(role: "assistant", content: "Sorry, try again.")
    end
  end

  def slot_change_prompt
    slot = @forced_candidate_slots.first
    "Regenerate this outfit by changing only the #{slot} slot. " \
      "Treat #{slot} as the only missing slot and keep all other slots exactly as they are. " \
      "Do not use item_id #{@excluded_item_ids.first} for #{slot}."
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def redirect_path_for_outfit(outfit)
    return_to = params[:return_to].to_s
    item_id = params[:item_id].presence

    if return_to == "new"
      new_outfit_path(outfit_id: outfit.id, item_id: item_id)
    else
      edit_outfit_path(outfit, item_id: item_id)
    end
  end
end
