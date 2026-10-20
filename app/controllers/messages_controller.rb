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
    apply_suggestions_to_outfit!(JSON.parse(@message.content))
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
      apply_suggestions_to_outfit!(suggestions)
      redirect_to redirect_path_for_outfit(@outfit)
    else
      replace_assistant_message("Sorry, try again.")
      redirect_to outfit_path(@outfit), alert: "OOPS, something went wrong. Please try again!"
    end
  end

  # Returns the parsed suggestions Array, or nil after AI_ATTEMPTS bad replies. Saves nothing.
  def fetch_suggestions
    AI_ATTEMPTS.times do
      parsed = JSON.parse(ai_response.content)
      return parsed if parsed.is_a?(Array)
    rescue JSON::ParserError
      next
    end
    nil
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
    suggestions = fetch_suggestions
    if suggestions
      @outfit.messages.create!(role: "assistant", content: suggestions.to_json)
      apply_suggestions_to_outfit!(suggestions)
    else
      @outfit.messages.create!(role: "assistant", content: "Sorry, try again.")
    end
    redirect_to redirect_path_for_outfit(@outfit)
  end

  def slot_change_prompt
    slot = @forced_candidate_slots.first
    "Regenerate this outfit by changing only the #{slot} slot. " \
      "Treat #{slot} as the only missing slot and keep all other slots exactly as they are. " \
      "Do not use item_id #{@excluded_item_ids.first} for #{slot}."
  end

  # currently the ai doesn't have ids for the items you selected at the start.
  # For now its ok but later we may need to add that.
  def ai_response
    chat = RubyLLM.chat
    chat.with_instructions(StylistPrompt::SYSTEM)
    @outfit.messages.where.not(id: @message.id).each do |msg|
      display_content = msg.content
      if msg.role == 'assistant'
        begin
          json_content = JSON.parse(msg.content)
          display_content =
            case json_content
            when Hash
              json_content['style_advice'].presence || msg.content
            when Array
              json_content
            .map { |entry| entry.is_a?(Hash) ? entry['style_comment'].presence || entry['item_name'] : nil }
            .compact
            .join("\n")
            .presence || msg.content
            else
              msg.content
            end
        rescue JSON::ParserError
          display_content = msg.content
        end
      end
      chat.add_message(role: msg.role, content: display_content)
    end
    current_items = @outfit.items.map do |item|
      {
        item_id: item.id,
        category: item.category,
        slot: item.slot,
        description: item.description,
        name: item.name
      }
    end.to_json

    candidate_items_scope =
      if @forced_candidate_slots.present?
        Item.where(user_id: @outfit.user_id, slot: @forced_candidate_slots)
      else
        @outfit.candidate_items_for_missing_slots
      end
    candidate_items_scope = candidate_items_scope.where.not(id: @excluded_item_ids) if @excluded_item_ids.present?

    candidates = candidate_items_scope.map do |item|
      {
        item_id: item.id,
        category: item.category,
        slot: item.slot,
        description: item.description,
        name: item.name
      }
    end.to_json
    chat.ask("#{@message.content} these are the current items in this outfit: #{current_items}. " \
             "Here are the items that I own that you can use to suggest me an outfit. candidates: #{candidates}.")
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def apply_suggestions_to_outfit!(suggestions)
    suggestions.each do |suggestion|
      item = Item.find_by(id: suggestion["item_id"], user_id: current_user.id)
      next unless item

      slot = suggestion["slot"]
      next if slot.blank?

      outfit_item = @outfit.outfit_items.find_or_initialize_by(slot: slot)
      outfit_item.item = item
      outfit_item.save!
      @outfit.outfit_items.where(slot: slot).where.not(id: outfit_item.id).delete_all
    end
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
