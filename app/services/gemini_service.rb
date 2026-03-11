# app/services/gemini_service.rb
class GeminiService
  def self.generate_try_on(base:, items:)
    prompt = "We sent you a person's image. Synthesize an image of the person in the photo wearing these clothes."
    attachments = items.map { |item| item.blob.url }
    attachments << base.blob.url

    image_chat = RubyLLM.chat(model: "gemini-2.5-flash-image")
    reply = image_chat.ask(prompt, with: { images: attachments })
    extract_generated_image_source(reply)
  end

  def self.extract_generated_image_source(reply)
    content = reply.content

    attachment =
      if reply.respond_to?(:attachments) && reply.attachments.present?
        reply.attachments.first
      elsif content.is_a?(Hash)
        (content[:attachments] || content["attachments"] || []).first
      elsif content.is_a?(Array)
        find_attachment_in_array(content)
      end

    source =
      if attachment.respond_to?(:source)
        attachment.source
      elsif attachment.is_a?(Hash)
        attachment[:source] || attachment["source"]
      end

    return source if source.present?

    raise "No generated image attachment returned by LLM"
  end

  def self.find_attachment_in_array(content)
    content.each do |entry|
      return entry if entry.respond_to?(:source)

      next unless entry.is_a?(Hash)

      nested = (entry[:attachments] || entry["attachments"] || []).first
      return nested if nested.present?

      return entry if entry[:source].present? || entry["source"].present?
    end

    nil
  end
end
