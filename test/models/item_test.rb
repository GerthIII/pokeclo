require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "a new item defaults to wishlist" do
    item = users(:alice).items.build(name: "x", description: "x", category: "casual", slot: "top")
    item.valid?
    assert item.wishlist?
  end

  test "an invalid status is invalid, not an exception" do
    item = Item.new(status: "bogus")
    assert_not item.valid?
    assert item.errors.key?(:status)
  end

  test "fixture statuses map to enum names" do
    assert items(:alice_top).owned?
    assert items(:alice_bottom).wishlist?
  end

  %i[name description category slot].each do |attribute|
    test "an item is invalid without #{attribute}" do
      item = users(:alice).items.build(name: "x", description: "x", category: "casual", slot: "top")
      item[attribute] = nil
      assert_not item.valid?
      assert item.errors.key?(attribute)
    end
  end
end
