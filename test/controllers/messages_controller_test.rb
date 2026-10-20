require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  FakeReply = Struct.new(:content)

  class FakeChat
    def initialize(content) = @content = content
    def with_instructions(_prompt) = self
    def add_message(**) = self
    def ask(_prompt) = FakeReply.new(@content)
  end

  # Replies come from a list, in order (the last one repeats). Counts calls.
  class SequenceChat
    attr_reader :calls

    def initialize(*contents)
      @contents = contents
      @calls = 0
    end

    def with_instructions(_prompt) = self
    def add_message(**) = self

    def ask(_prompt)
      reply = @contents[[@calls, @contents.size - 1].min]
      @calls += 1
      FakeReply.new(reply)
    end
  end

  setup do
    @outfit = outfits(:alice_outfit)
    @reply = [{ item_id: items(:alice_top).id, slot: "top", item_name: "Tee" }].to_json
  end

  test "another user cannot post into someone else's outfit" do
    sign_in users(:bob)
    assert_no_difference "Message.count" do
      post outfit_messages_path(@outfit), params: { message: { content: "hi" } }
    end
    assert_response :not_found
  end

  test "another user cannot change a slot on someone else's outfit" do
    sign_in users(:bob)
    assert_no_difference "Message.count" do
      post change_slot_outfit_message_path(@outfit, messages(:alice_assistant_message), slot: "top")
    end
    assert_response :not_found
  end

  test "owner can post a message and get AI suggestions" do
    sign_in users(:alice)
    RubyLLM.stub :chat, FakeChat.new(@reply) do
      post outfit_messages_path(@outfit), params: { message: { content: "hi" } }
    end
    assert_redirected_to edit_outfit_path(@outfit)
    assert_equal @reply, @outfit.messages.where(role: "assistant").sole.content
  end

  test "owner can change a slot" do
    sign_in users(:alice)
    RubyLLM.stub :chat, FakeChat.new(@reply) do
      post change_slot_outfit_message_path(@outfit, messages(:alice_assistant_message), slot: "top")
    end
    assert_redirected_to edit_outfit_path(@outfit, item_id: nil)
  end

  test "bad, bad, good JSON retries and leaves one assistant message" do
    sign_in users(:alice)
    chat = SequenceChat.new("nope", "still nope", @reply)
    RubyLLM.stub(:chat, chat) { post outfit_messages_path(@outfit), params: { message: { content: "hi" } } }
    assert_equal 3, chat.calls
    assert_redirected_to edit_outfit_path(@outfit)
    assert_includes @outfit.reload.items, items(:alice_top)
    assert_equal @reply, @outfit.messages.where(role: "assistant").sole.content
  end

  test "bad JSON three times gives up with one Sorry message" do
    sign_in users(:alice)
    chat = SequenceChat.new("nope")
    RubyLLM.stub(:chat, chat) { post outfit_messages_path(@outfit), params: { message: { content: "hi" } } }
    assert_equal 3, chat.calls
    assert_redirected_to outfit_path(@outfit)
    assert_equal "OOPS, something went wrong. Please try again!", flash[:alert]
    assert_equal ["Sorry, try again."], @outfit.messages.where(role: "assistant").pluck(:content)
  end

  test "valid JSON that is not an array counts as a failed attempt" do
    sign_in users(:alice)
    chat = SequenceChat.new('{"a":1}', @reply)
    RubyLLM.stub(:chat, chat) { post outfit_messages_path(@outfit), params: { message: { content: "hi" } } }
    assert_equal 2, chat.calls
    assert_redirected_to edit_outfit_path(@outfit)
  end

  test "empty content redirects with an alert and never calls the AI" do
    sign_in users(:alice)
    RubyLLM.stub(:chat, ->(*) { flunk "RubyLLM.chat must not be called" }) do
      assert_no_difference "Message.count" do
        post outfit_messages_path(@outfit), params: { message: { content: "" } }
      end
    end
    assert_redirected_to edit_outfit_path(@outfit, item_id: nil)
    assert_equal "Message can't be blank.", flash[:alert]
  end

  test "change_slot with bad JSON three times leaves one Sorry message" do
    sign_in users(:alice)
    chat = SequenceChat.new("nope")
    assert_difference -> { @outfit.messages.where(content: "Sorry, try again.").count }, 1 do
      RubyLLM.stub(:chat, chat) do
        post change_slot_outfit_message_path(@outfit, messages(:alice_assistant_message), slot: "top")
      end
    end
    assert_equal 3, chat.calls
    assert_redirected_to edit_outfit_path(@outfit, item_id: nil)
  end
end
