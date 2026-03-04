class MessagesController < ApplicationController
  def new
    @outfit = Outfit.find(params[:outfit_id])
    @messages = @outfit.messages
    @message = Message.new
  end

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
    chat.with_instructions("You are a helpful fashion assistant helping the user think through their outfit.")
    @outfit.messages.where.not(id: @message.id).each do |msg|
      chat.add_message(role: msg.role, content: msg.content)
    end
    chat.ask(@message.content)
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
