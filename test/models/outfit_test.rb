require "test_helper"

class OutfitTest < ActiveSupport::TestCase
  setup { @outfit = outfits(:alice_outfit) }

  test "slot item from another user's closet is invalid" do
    @outfit.top_item_id = items(:bob_top).id
    assert_not @outfit.valid?
    assert_includes @outfit.errors.full_messages, "Those items aren't in your closet."
  end

  test "slot item from the owner's closet is valid" do
    @outfit.top_item_id = items(:alice_top).id
    assert @outfit.valid?
  end

  test "blank slot ids are valid" do
    @outfit.top_item_id = ""
    assert @outfit.valid?
    assert outfits(:bob_outfit).valid?
  end

  test "outfit without a user reports the missing user instead of crashing" do
    outfit = Outfit.new(name: "x", top_item_id: items(:alice_top).id)
    assert_not outfit.valid?
  end
end
