# DECISION: The AI conversation lives in a service so the controller only handles HTTP.
#   Rejected: a controller concern (passes the linter but only moves the fat).
#   It still calls RubyLLM.chat so tests can stub one seam.
class StylistChat
  def initialize(outfit:, message:, candidate_slots: nil, excluded_item_ids: [], locked_item_ids: [])
    @outfit = outfit
    @message = message
    @candidate_slots = candidate_slots
    @excluded_item_ids = excluded_item_ids
    @locked_item_ids = locked_item_ids
  end

  def ask
    chat = build_chat
    replay_history(chat)
    chat.ask("#{@message.content} these are the current items in this outfit: #{item_payload(@outfit.items)}. " \
             "Here are the items that I own that you can use to suggest me an outfit. " \
             "candidates: #{item_payload(candidate_scope)}.#{locked_sentence}")
  end

  private

  def build_chat
    chat = RubyLLM.chat
    chat.with_instructions(StylistPrompt::SYSTEM)
    chat
  end

  def replay_history(chat)
    @outfit.messages.where.not(id: @message.id).each do |msg|
      chat.add_message(role: msg.role, content: display_content(msg))
    end
  end

  def display_content(msg)
    return msg.content unless msg.role == 'assistant'

    display_from_json(JSON.parse(msg.content), msg.content)
  rescue JSON::ParserError
    msg.content
  end

  def display_from_json(parsed, raw)
    case parsed
    when Hash then parsed['style_advice'].presence || raw
    when Array then array_text(parsed) || raw
    else raw
    end
  end

  def array_text(entries)
    entries
      .map { |entry| entry.is_a?(Hash) ? entry['style_comment'].presence || entry['item_name'] : nil }
      .compact
      .join("\n")
      .presence
  end

  # currently the ai doesn't have ids for the items you selected at the start.
  # For now its ok but later we may need to add that.
  def item_payload(items)
    items.map do |item|
      { item_id: item.id, category: item.category, slot: item.slot, description: item.description, name: item.name }
    end.to_json
  end

  # Only ids still in the outfit count, so clearing a slot releases its lock (and a forged id does nothing).
  def locked_sentence
    locked = @outfit.items.where(id: @locked_item_ids)
    locked.empty? ? "" : " Never change these items: #{item_payload(locked)}."
  end

  def candidate_scope
    scope = base_candidates
    @excluded_item_ids.present? ? scope.where.not(id: @excluded_item_ids) : scope
  end

  # DECISION: A full outfit offers all of the owner's items (wishlist included, to show how a planned purchase fits).
  #   Rejected: always all items (the AI may replace the starter item the user picked in the Fitting Room).
  #   Rejected: leave it (once the outfit is full the AI gets 0 candidates, so follow-up chat looks broken).
  def base_candidates
    if @candidate_slots.present?
      Item.where(user_id: @outfit.user_id, slot: @candidate_slots)
    elsif @outfit.missing_slots.any?
      @outfit.candidate_items_for_missing_slots
    else
      Item.where(user_id: @outfit.user_id)
    end
  end
end
