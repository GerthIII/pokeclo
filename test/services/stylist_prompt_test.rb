require "test_helper"

class StylistPromptTest < ActiveSupport::TestCase
  test "SYSTEM is a non-empty string containing the keys the app parses" do
    assert_kind_of String, StylistPrompt::SYSTEM
    assert_not_empty StylistPrompt::SYSTEM
    assert_includes StylistPrompt::SYSTEM, "item_id"
    assert_includes StylistPrompt::SYSTEM, "slot"
  end
end
