# DECISION: The AI conversation lives in a service so the controller only handles HTTP.
#   Rejected: a controller concern (passes the linter but only moves the fat).
#   It still calls RubyLLM.chat so tests can stub one seam.
class StylistChat
  def initialize(outfit:, message:, candidate_slots: nil, excluded_item_ids: [])
    @outfit = outfit
    @message = message
    @candidate_slots = candidate_slots
    @excluded_item_ids = excluded_item_ids
  end

  def ask
    chat = build_chat
    replay_history(chat)
    chat.ask("#{@message.content} these are the current items in this outfit: #{item_payload(@outfit.items)}. " \
             "Here are the items that I own that you can use to suggest me an outfit. " \
             "candidates: #{item_payload(candidate_scope)}.")
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

  def candidate_scope
    scope =
      if @candidate_slots.present?
        Item.where(user_id: @outfit.user_id, slot: @candidate_slots)
      else
        @outfit.candidate_items_for_missing_slots
      end
    @excluded_item_ids.present? ? scope.where.not(id: @excluded_item_ids) : scope
  end
end
