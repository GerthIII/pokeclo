require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  FakeReply = Struct.new(:content)

  class FakeChat
    def initialize(content) = @content = content
    def with_instructions(_prompt) = self
    def add_message(**) = self
    def ask(_prompt) = FakeReply.new(@content)
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

  test "another user cannot confirm someone else's message" do
    sign_in users(:bob)
    assert_no_difference ["Message.count", "OutfitItem.count"] do
      post confirm_outfit_message_path(@outfit, messages(:alice_assistant_message))
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
end
