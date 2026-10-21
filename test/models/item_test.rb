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

  def new_item_for(user)
    user.items.build(name: "x", description: "x", category: "casual", slot: "top")
  end

  test "the next item is invalid when the user has the maximum" do
    fill_closet(users(:alice))
    item = new_item_for(users(:alice))
    assert_not item.valid?
    assert_includes item.errors[:base], "You can have at most 100 items. Delete one to add another."
  end

  test "another user is unaffected by the limit" do
    fill_closet(users(:alice))
    assert new_item_for(users(:bob)).valid?
  end

  test "updating an item is still valid at the limit" do
    fill_closet(users(:alice))
    assert items(:alice_top).update(name: "Renamed")
  end

  test "an item is valid just under the limit" do
    fill_closet(users(:alice), Item::MAX_PER_USER - 1)
    assert new_item_for(users(:alice)).valid?
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
