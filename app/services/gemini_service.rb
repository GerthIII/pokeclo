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
    source = source_of(find_attachment(reply))
    return source if source.present?

    raise "No generated image attachment returned by LLM"
  end

  def self.find_attachment(reply)
    return reply.attachments.first if reply.respond_to?(:attachments) && reply.attachments.present?

    content = reply.content
    case content
    when Hash then first_nested_attachment(content)
    when Array then find_attachment_in_array(content)
    end
  end

  def self.source_of(attachment)
    if attachment.respond_to?(:source)
      attachment.source
    elsif attachment.is_a?(Hash)
      attachment[:source] || attachment["source"]
    end
  end

  def self.first_nested_attachment(hash)
    (hash[:attachments] || hash["attachments"] || []).first
  end

  def self.find_attachment_in_array(content)
    content.lazy.filter_map { |entry| attachment_in_entry(entry) }.first
  end

  def self.attachment_in_entry(entry)
    return entry if entry.respond_to?(:source)
    return unless entry.is_a?(Hash)

    nested = first_nested_attachment(entry)
    return nested if nested.present?

    entry if entry[:source].present? || entry["source"].present?
  end
end
