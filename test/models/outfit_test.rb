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

  test "an outfit is invalid without a name" do
    outfit = Outfit.new(user: users(:alice))
    assert_not outfit.valid?
    assert outfit.errors.key?(:name)
  end

  test "missing_slots lists every slot the outfit has no item for" do
    assert_equal %w[outer bottom footwear].sort, @outfit.missing_slots.sort
    assert_not_includes @outfit.missing_slots, "top"
  end

  test "candidate_items_for_missing_slots returns only the owner's items" do
    bob_jeans = users(:bob).items.create!(name: "Bob's Jeans", description: "x", category: "casual", slot: "bottom")
    candidates = @outfit.candidate_items_for_missing_slots

    assert_includes candidates, items(:alice_bottom)
    assert_not_includes candidates, bob_jeans
    assert candidates.all? { |item| item.user_id == users(:alice).id }
  end

  test "normalize_outfit_item_slots! fills a blank slot from the item" do
    outfit_item = outfit_items(:alice_outfit_top)
    outfit_item.update_column(:slot, nil)
    @outfit.normalize_outfit_item_slots!
    assert_equal "top", outfit_item.reload.slot
  end

  test "apply_suggestions! sets the slot from the user's own item" do
    @outfit.apply_suggestions!([{ "item_id" => items(:alice_bottom).id, "slot" => "bottom" }])
    assert_equal items(:alice_bottom), @outfit.outfit_items.find_by(slot: "bottom").item
  end

  test "apply_suggestions! skips a deleted item without error" do
    deleted_id = items(:alice_bottom).id
    items(:alice_bottom).destroy
    assert_nothing_raised { @outfit.apply_suggestions!([{ "item_id" => deleted_id, "slot" => "bottom" }]) }
    assert_not_includes @outfit.reload.filled_slots, "bottom"
  end

  test "apply_suggestions! ignores another user's item" do
    assert_no_difference "OutfitItem.count" do
      @outfit.apply_suggestions!([{ "item_id" => items(:bob_top).id, "slot" => "top" }])
    end
    assert_equal items(:alice_top), @outfit.outfit_items.find_by(slot: "top").item
  end

  test "create_slot_items! creates rows only for present ids" do
    @outfit.outfit_items.destroy_all
    @outfit.top_item_id = items(:alice_top).id
    @outfit.bottom_item_id = items(:alice_bottom).id
    @outfit.outer_item_id = ""
    @outfit.create_slot_items!
    assert_equal({ "top" => items(:alice_top).id, "bottom" => items(:alice_bottom).id },
                 @outfit.outfit_items.pluck(:slot, :item_id).to_h)
  end

  test "hydrate_slot_item_ids! sets virtual attributes from outfit items" do
    @outfit.hydrate_slot_item_ids!
    assert_equal items(:alice_top).id, @outfit.top_item_id
    assert_nil @outfit.bottom_item_id
    assert_nil @outfit.outer_item_id
    assert_nil @outfit.footwear_item_id
  end

  test "assign_slot_item sets the matching virtual attribute" do
    @outfit.assign_slot_item(items(:alice_bottom))
    assert_equal items(:alice_bottom).id, @outfit.bottom_item_id
  end

  test "assign_slot_item ignores an unknown slot" do
    @outfit.assign_slot_item(Item.new(id: 1, slot: "hat"))
    assert_nil @outfit.top_item_id
  end

  test "latest_suggestion returns the newest usable assistant message" do
    message, ids = @outfit.latest_suggestion
    assert_equal messages(:alice_assistant_message), message
    assert_equal({ "top" => items(:alice_top).id }, ids)
  end

  test "latest_suggestion skips a newer assistant message with invalid JSON" do
    @outfit.messages.create!(role: "assistant", content: "not json", created_at: 1.minute.from_now)
    message, ids = @outfit.latest_suggestion
    assert_equal messages(:alice_assistant_message), message
    assert_equal({ "top" => items(:alice_top).id }, ids)
  end

  test "latest_suggestion is empty without assistant messages" do
    @outfit.messages.where(role: "assistant").destroy_all
    assert_equal [nil, {}], @outfit.latest_suggestion
  end
end
