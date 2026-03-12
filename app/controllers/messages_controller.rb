class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<-PROMPT
    You are a Senior Fashion Stylist.
    I am a beginner who gets overwhelmed by choices.
    Complete an outfit by filling the empty slots using items from my provided closet.

    ### RULES:
    1. **Strict Taxonomy:** You must NOT invent categories. For every item you select, you MUST use the exact "category" and "slot" string provided in the closet data.
    2. **Fill the Gaps:** For every empty slot (Top, Bottom, Shoes, Accessories), select the best-matching item from my closet. If I already provided an item for that slot do not swap it. Only fill the slots that are not being provided.
    3. **Styling Rationale:** Provide a "style_comment" for every item. Use simple fashion theory (e.g., "The slim top balances the wide pants").
    4. **Tone:** Conversational, short, and jargon-free. Avoid run-on sentences and use plain language.
    5. **Format:** You must order the items in this order: outer, top, bottom, footwear. This is to keep things looking nice.

    ### OUTPUT FORMAT:
    Return ONLY a JSON array of objects. No prose, no intro, no markdown code blocks.

    Required JSON Keys:
    - "item_id": (integer) this must be the id of one of the items that I provided as candidate or current item.
    - "item_name": This must be the name of one of the items I provided as a candidate or current item. It needs to match the id of that item.
    - "status": "selected"
    - "category": (Must match the closet data exactly)
    - "slot": (Must match the closet data exactly)
    - "style_comment": (Your brief explanation)

    ### SAMPLE JSON STRUCTURE:
    [
      {
        "item_id": 39,
        "item_name": "shirt"
        "status": "selected",
        "category": "sportswear",
        "slot": "top",
        "style_comment": "This tee adds a pop of color to an otherwise neutral look."
      }
    ]
  PROMPT

  # Sample AI Response (The Template)
  # Styling Your Outfit: "Modern Heritage"
  # Outer (Sports Jacket):
  # The blue adds a subtle pop of color that doesn't clash with the monochrome palette, maintaining the aesthetic.

  # Top (Adidas x Oasis Ringer Tee):
  # The cream base provides a soft, neutral foundation, while the black part at the neck draws attention to your face.

  # Bottom (Black Hummel Track Pants):
  # By choosing black bottoms, we create a "Vertical Column of Color" with the black accents on the shirt.
  # The white panels on the legs mirror the sporty vibe of the Adidas stripes, creating visual harmony.

  # Footwear (White Adizero Cleats):
  # The crisp white of the shoes "sandwiches" the outfit, pulling the cream/white from the top down to the feet.
  # This prevents the outfit from feeling "bottom-heavy" with all-black pants.

  def create
    @outfit = Outfit.find(params[:outfit_id])
    @message = @outfit.messages.build(message_params)
    authorize @message
    @message.role = "user"

    if @message.save
      response = ai_response

      begin
        suggestions = JSON.parse(response.content)

        # 古いAI結果削除
        @outfit.messages.where(role: "assistant").destroy_all

        # 新しいAI結果保存
        @outfit.messages.create!(
          role: "assistant",
          content: suggestions.to_json
        )

        apply_suggestions_to_outfit!(suggestions)
      rescue JSON::ParserError
        @outfit.messages.where(role: "assistant").destroy_all

        Message.create!(
          outfit: @outfit,
          role: "assistant",
          content: "Sorry, try again."
        )
      end

      redirect_to redirect_path_for_outfit(@outfit)
    else
      render outfits_path, status: :unprocessable_entity
    end
  end

  def confirm
    @outfit = Outfit.find(params[:outfit_id])
    @message = @outfit.messages.find(params[:id])
    authorize @message
    suggestions = JSON.parse(@message.content)
    apply_suggestions_to_outfit!(suggestions)
    redirect_to edit_outfit_path(@outfit)
  rescue JSON::ParserError
    redirect_to new_outfit_path(@outfit), alert: "Could not apply suggestions."
  end

  def change_slot
    @outfit = Outfit.find(params[:outfit_id])
    @message = @outfit.messages.find(params[:id])
    authorize @message, :confirm?

    slot = params[:slot].to_s
    if slot.blank? || !Outfit::SLOTS.include?(slot)
      redirect_to edit_outfit_path(@outfit), alert: "Invalid slot."
      return
    end

    current_item_id = params[:current_item_id].presence&.to_i
    candidate_scope = Item.where(user_id: current_user.id, slot: slot)
    candidate_scope = candidate_scope.where.not(id: current_item_id) if current_item_id.present?
    if candidate_scope.none?
      redirect_to edit_outfit_path(@outfit), alert: "No alternative items available for #{slot}."
      return
    end

    @forced_candidate_slots = [slot]
    @excluded_item_ids = [current_item_id].compact

    prompt = "Regenerate this outfit by changing only the #{slot} slot. " \
             "Treat #{slot} as the only missing slot and keep all other slots exactly as they are. " \
             "Do not use item_id #{current_item_id} for #{slot}."

    user_message = @outfit.messages.build(role: "user", content: prompt)
    if user_message.save
      @message = user_message
      response = ai_response
      suggestions = JSON.parse(response.content)
      @outfit.messages.create!(role: "assistant", content: suggestions.to_json)
      apply_suggestions_to_outfit!(suggestions)
      redirect_to redirect_path_for_outfit(@outfit)
    else
      redirect_to redirect_path_for_outfit(@outfit), alert: "Could not regenerate this slot."
    end
  rescue JSON::ParserError
    @outfit.messages.create!(role: "assistant", content: "Sorry, try again.")
    redirect_to redirect_path_for_outfit(@outfit), alert: "Could not parse AI suggestions."
  end

  private

  # currently the ai doesn't have ids for the items you selected at the start. For now its ok but later we may need to add that.
  def ai_response
    chat = RubyLLM.chat
    chat.with_instructions(SYSTEM_PROMPT)
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
    chat.ask("#{@message.content} these are the current items in this outfit: #{current_items}. Here are the items that I own that you can use to suggest me an outfit. candidates: #{candidates}.")
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
