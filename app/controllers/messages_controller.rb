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
    # Outer (Sports Jacket): The blue adds a subtle pop of color that doesn't clash with the monochrome palette, maintaining the aesthetic.

    # Top (Adidas x Oasis Ringer Tee): The cream base provides a soft, neutral foundation, while the black ribbing at the neck draws attention to your face. This serves as the "statement piece" of the look.

    # Bottom (Black Hummel Track Pants): By choosing black bottoms, we create a "Vertical Column of Color" with the black accents on the shirt. The white chevron panels on the legs mirror the sporty vibe of the Adidas stripes, creating visual harmony.

    # Footwear (White Adizero Cleats): The crisp white of the shoes "sandwiches" the outfit, pulling the cream/white from the top down to the feet. This prevents the outfit from feeling "bottom-heavy" with all-black pants.


  def create
    @outfit = Outfit.find(params[:outfit_id])
    @message = @outfit.messages.build(message_params)
    authorize @message
    @message.role = "user"
    if @message.save
      response = ai_response
      begin
        suggestions = JSON.parse(response.content)
        @outfit.messages.build(role: 'assistant', content: suggestions.to_json)
        @outfit.save
      rescue JSON::ParserError
        Message.create(outfit: @outfit, content: "Sorry, try again.", role: "assistant")
      end
      redirect_to chat_outfit_path(@outfit)
    else
      render outfits_path, status: :unprocessable_entity
    end
  end

  def confirm
    @outfit = Outfit.find(params[:outfit_id])
    @message = @outfit.messages.find(params[:id])
    authorize @message
    suggestions = JSON.parse(@message.content)
    suggestions.each do |suggestion|
      next if @outfit.filled_slots.include?(suggestion["slot"])
      item = Item.find_by(id: suggestion["item_id"], user_id: current_user.id)
      next unless item
      OutfitItem.create(outfit: @outfit, item: item, slot: suggestion["slot"])
    end
    redirect_to chat_outfit_path(@outfit)
  rescue JSON::ParserError
    redirect_to chat_outfit_path(@outfit), alert: "Could not apply suggestions."
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
          display_content = json_content['style_advice'] || msg.content
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
    candidates = @outfit.candidate_items_for_missing_slots.map do |item|
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
end
