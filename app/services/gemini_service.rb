# app/services/gemini_service.rb
class GeminiService
  def self.generate_try_on(base:, items:)
    # 1. Initialize the client (using your LLM configuration)
    prompt = "We sent you a person's image. Synthesize an image of the person in the photo wearing these clothes."
    attachments = items.map { |item| item.blob.url }
    attachments << base
    # Call chat with the prompt and the attachments array
    image_chat = RubyLLM.chat(model: "gemini-2.5-flash-image")
    reply = image_chat.ask(prompt, with: { images: attachments })
    image = reply.content[:attachments][0].source
    # Return the content (the generated image data)
  end
end
