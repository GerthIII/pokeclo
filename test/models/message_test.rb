require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "assistant fixture references alice_top's real id" do
    suggestions = JSON.parse(messages(:alice_assistant_message).content)
    assert_equal items(:alice_top).id, suggestions.first["item_id"]
  end

  test "a message is invalid without role" do
    message = messages(:alice_user_message)
    message.role = nil
    assert_not message.valid?
    assert message.errors.key?(:role)
  end

  test "a message is invalid without content" do
    message = messages(:alice_user_message)
    message.content = nil
    assert_not message.valid?
    assert message.errors.key?(:content)
  end
end
