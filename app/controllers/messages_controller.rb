class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<-PROMPT
    You are a Senior Fashion Stylist.
    I am a beginner who gets overwhelmed by choices.
    Complete an outfit by filling the empty slots using items from my provided closet.
    Your goal is to create a cohesive, intentional look.
    Fill the Gaps: For every empty slot (Top, Bottom, Shoes, Accessories), select the best-matching item from my closet.
    Styling Rationale: For every item in the final outfit (both my selections and yours), provide a "Styling Note." Explain the fashion theory behind it (e.g., "The slim silhouette of the top balances the wide-leg trousers" or "The navy blue creates a sophisticated monochromatic base").

    Sample AI Response (The Template)
    Styling Your Outfit: "Modern Heritage"
    Outer (Sports Jacket): The blue adds a subtle pop of color that doesn't clash with the monochrome palette, maintaining the aesthetic.

    Top (Adidas x Oasis Ringer Tee): The cream base provides a soft, neutral foundation, while the black ribbing at the neck draws attention to your face. This serves as the "statement piece" of the look.

    Bottom (Black Hummel Track Pants): By choosing black bottoms, we create a "Vertical Column of Color" with the black accents on the shirt. The white chevron panels on the legs mirror the sporty vibe of the Adidas stripes, creating visual harmony.

    Footwear (White Adizero Cleats): The crisp white of the shoes "sandwiches" the outfit, pulling the cream/white from the top down to the feet. This prevents the outfit from feeling "bottom-heavy" with all-black pants.

  PROMPT

  def create
    @outfit = Outfit.find(params[:outfit_id])
    @message = @outfit.messages.build(message_params)
    @message.role = "user"
    if @message.save
      response = ai_response
      @outfit.messages.build(role: 'assistant', content: response.content)
      @outfit.save
      redirect_to new_outfit_message_path(@outfit)
    else
      render "messages/new", status: :unprocessable_entity
    end
  end

  private

  def ai_response
    chat = RubyLLM.chat
    chat.with_instructions(SYSTEM_PROMPT)
    @outfit.messages.where.not(id: @message.id).each do |msg|
      chat.add_message(role: msg.role, content: msg.content)
    end
    descriptions = @outfit.items.map do |item|
      item.description
    end
    candidates = @outfit.candidate_items_for_missing_slots.map do |item|
      item.description
    end
    chat.ask("#{@message.content} these are the current items in this outfit. number of items: #{descriptions.count} descriptions of items: #{descriptions.join("-")}. Here are the items that I own that you can use to suggest me an outfit. Number of candidates: #{candidates.count}, candidates descriptions: #{candidates.join("-")}.")
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
