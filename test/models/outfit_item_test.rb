require "test_helper"

class OutfitItemTest < ActiveSupport::TestCase
  test "item from another user is invalid" do
    outfit_item = OutfitItem.new(outfit: outfits(:alice_outfit), item: items(:bob_top), slot: "top")
    assert_not outfit_item.valid?
  end

  test "item from the outfit owner is valid" do
    outfit_item = OutfitItem.new(outfit: outfits(:alice_outfit), item: items(:alice_top), slot: "top")
    assert outfit_item.valid?
  end

  test "existing fixture is valid" do
    assert outfit_items(:alice_outfit_top).valid?
  end
end
