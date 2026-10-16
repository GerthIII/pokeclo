require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "assistant fixture references alice_top's real id" do
    suggestions = JSON.parse(messages(:alice_assistant_message).content)
    assert_equal items(:alice_top).id, suggestions.first["item_id"]
  end
end
