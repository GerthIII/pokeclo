require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixtures load and alice is valid" do
    assert users(:alice).valid?
  end

  test "destroying a user removes their data and leaves other users' data alone" do
    alice = users(:alice)
    bob_counts = bob_counts_for(users(:bob))
    outfit_id = outfits(:alice_outfit).id
    alice.destroy!
    assert_equal 0, Item.where(user_id: alice.id).count
    assert_equal 0, Outfit.where(user_id: alice.id).count
    assert_equal 0, OutfitItem.where(outfit_id: outfit_id).count
    assert_equal 0, Message.where(outfit_id: outfit_id).count
    assert_equal bob_counts, bob_counts_for(users(:bob))
  end

  test "destroying a user whose item has a photo does not raise" do
    items(:alice_top).photo.attach(
      io: File.open(file_fixture("profile.png")), filename: "profile.png", content_type: "image/png"
    )
    assert_nothing_raised { users(:alice).destroy! }
  end

  private

  def bob_counts_for(user)
    [Item.where(user: user).count, Outfit.where(user: user).count,
     OutfitItem.joins(:outfit).where(outfits: { user_id: user.id }).count,
     Message.joins(:outfit).where(outfits: { user_id: user.id }).count]
  end
end
