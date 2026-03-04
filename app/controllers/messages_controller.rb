class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<-PROMPT
    You are a helpful fashion assistant.
    I am a beginner at fashion who tends to get overwhelmed when buying clothes.
    Help me by building outfits to facilitate buying while in the store.
    Provide an item for each slot that I didn't select using items from my closet.
    Also provide a json in your response that includes all the details of each item.
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
