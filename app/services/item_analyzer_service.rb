class ItemAnalyzerService
  SLOTS = Item::SLOT
  CATEGORIES = Item::CATEGORY

  def self.call(photo)
    chat = RubyLLM.chat(model: "gemini-2.5-flash")

    response = chat.ask(<<~PROMPT, with: photo)
      You are a fashion assistant. Analyze this clothing item photo and respond with ONLY valid JSON, no markdown, no code fences.

      Rules:
      - slot must be one of: #{SLOTS.join(", ")}
      - category must be one of: #{CATEGORIES.join(", ")}
      - name should be short (2-5 words)
      - description should be 1-2 sentences about style, color, and material

      Respond with this exact JSON structure:
      {
        "name": "...",
        "description": "...",
        "category": "...",
        "slot": "..."
      }
    PROMPT

    result = JSON.parse(response.content)
    result["name"] = "#{result["category"]} #{result["slot"]}".strip if result["name"].blank?
    result
  rescue JSON::ParserError
    { error: "Could not analyze photo" }
  end
end
