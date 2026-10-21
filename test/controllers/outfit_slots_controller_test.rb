require "test_helper"

class OutfitSlotsControllerTest < ActionDispatch::IntegrationTest
  setup { @outfit = outfits(:alice_outfit) }

  def add_bottom
    @outfit.outfit_items.create!(item: items(:alice_bottom), slot: "bottom")
  end

  test "owner clears a slot and keeps the others" do
    add_bottom
    sign_in users(:alice)
    assert_difference "OutfitItem.count", -1 do
      delete outfit_slot_path(@outfit, "top", item_id: items(:alice_top).id)
    end
    assert_response :see_other
    assert_redirected_to edit_outfit_path(@outfit, item_id: items(:alice_top).id)
    assert_equal ["bottom"], @outfit.reload.filled_slots
  end

  test "another user's outfit is a 404 and unchanged" do
    sign_in users(:bob)
    assert_no_difference "OutfitItem.count" do
      delete outfit_slot_path(@outfit, "top")
    end
    assert_response :not_found
  end

  test "an unknown slot changes nothing and redirects with an alert" do
    sign_in users(:alice)
    assert_no_difference "OutfitItem.count" do
      delete outfit_slot_path(@outfit, "hat")
    end
    assert_redirected_to edit_outfit_path(@outfit)
    assert_equal "Unknown slot.", flash[:alert]
  end

  test "signed out is redirected to sign in" do
    delete outfit_slot_path(@outfit, "top")
    assert_redirected_to new_user_session_path
  end

  test "after clearing, the slot is missing and only its items are candidates" do
    sign_in users(:alice)
    delete outfit_slot_path(@outfit, "top")
    assert_includes @outfit.reload.missing_slots, "top"
    assert_equal [items(:alice_top)], @outfit.candidate_items_for_missing_slots.where(slot: "top").to_a
  end
end
