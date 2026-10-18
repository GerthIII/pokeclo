require "test_helper"

class OutfitTest < ActiveSupport::TestCase
  setup { @outfit = outfits(:alice_outfit) }

  test "fixture outfit is a draft" do
    assert @outfit.draft?
  end

  test "a new outfit defaults to draft and is valid" do
    outfit = Outfit.new(name: "x", user: users(:alice))
    assert outfit.draft?
    assert outfit.valid?
  end

  test "an invalid status is invalid, not an exception" do
    outfit = Outfit.new(name: "x", user: users(:alice), status: "bogus")
    assert_not outfit.valid?
    assert outfit.errors.key?(:status)
  end

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

  test "destroying an outfit removes its messages and outfit items" do
    assert_difference "Message.count", -2 do
      assert_difference "OutfitItem.count", -1 do
        @outfit.destroy!
      end
    end
  end

  test "outfit without a user reports the missing user instead of crashing" do
    outfit = Outfit.new(name: "x", top_item_id: items(:alice_top).id)
    assert_not outfit.valid?
  end
end
