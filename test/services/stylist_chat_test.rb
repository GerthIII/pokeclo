require "test_helper"

class StylistChatTest < ActiveSupport::TestCase
  FakeReply = Struct.new(:content)

  class RecordingChat
    attr_reader :instructions, :added, :asked

    def initialize
      @added = []
    end

    def with_instructions(prompt)
      @instructions = prompt
      self
    end

    def add_message(role:, content:)
      @added << { role: role, content: content }
      self
    end

    def ask(text)
      @asked = text
      FakeReply.new("[]")
    end
  end

  setup do
    @outfit = outfits(:alice_outfit)
    @message = @outfit.messages.create!(role: "user", content: "Something warm")
    @chat = RecordingChat.new
  end

  def run_chat(**)
    reply = nil
    RubyLLM.stub(:chat, @chat) { reply = StylistChat.new(outfit: @outfit, message: @message, **).ask }
    reply
  end

  test "returns the chat reply" do
    assert_equal "[]", run_chat.content
  end

  test "asks with the user's candidates and not another user's" do
    bob_bottom = items(:bob_top).dup.tap { |i| i.assign_attributes(slot: "bottom", name: "Bob Jeans") }
    bob_bottom.save!
    run_chat
    assert_includes @chat.asked, "\"item_id\":#{items(:alice_bottom).id}"
    assert_not_includes @chat.asked, "\"item_id\":#{bob_bottom.id}"
  end

  test "excludes excluded_item_ids from candidates" do
    run_chat(candidate_slots: ["bottom"], excluded_item_ids: [items(:alice_bottom).id])
    assert_not_includes @chat.asked, "\"item_id\":#{items(:alice_bottom).id}"
  end

  test "replays assistant JSON history as its style_comment text" do
    run_chat
    assistant = @chat.added.find { |m| m[:role] == "assistant" }
    assert_equal "Simple and clean.", assistant[:content]
    assert_not_includes @chat.added.pluck(:content), @message.content
  end

  test "uses the stylist system prompt" do
    run_chat
    assert_equal StylistPrompt::SYSTEM, @chat.instructions
  end
end
