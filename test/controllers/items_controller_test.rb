require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "another user's item show is a 404" do
    sign_in users(:bob)
    get item_path(items(:alice_top))
    assert_response :not_found
  end

  test "another user's item cannot be updated" do
    sign_in users(:bob)
    item = items(:alice_top)
    assert_no_changes -> { item.reload.attributes } do
      patch item_path(item), params: { item: { name: "hacked" } }
    end
    assert_response :not_found
    assert_equal "Alice's White Tee", item.reload.name
  end

  test "another user's item cannot be marked as bought" do
    sign_in users(:bob)
    item = items(:alice_bottom)
    assert_no_changes -> { item.reload.status } do
      patch mark_as_bought_item_path(item)
    end
    assert_response :not_found
  end

  test "mark as bought moves the item to the closet and makes no outfit" do
    sign_in users(:alice)
    item = items(:alice_bottom)
    assert_no_difference "Outfit.count" do
      patch mark_as_bought_item_path(item)
    end
    assert_response :see_other
    assert_redirected_to item_path(item)
    assert item.reload.owned?
  end

  test "mark as bought ignores create_outfit_with_ai" do
    sign_in users(:alice)
    item = items(:alice_bottom)
    assert_no_difference "Outfit.count" do
      patch mark_as_bought_item_path(item), params: { create_outfit_with_ai: true }
    end
    assert_redirected_to item_path(item)
    assert item.reload.owned?
  end

  test "mark as bought as JSON returns the new status" do
    sign_in users(:alice)
    item = items(:alice_bottom)
    patch mark_as_bought_item_path(item), as: :json
    assert_response :ok
    assert_equal({ "id" => item.id, "status" => "owned" }, response.parsed_body)
  end

  test "owner can view their item" do
    sign_in users(:alice)
    get item_path(items(:alice_top))
    assert_response :success
  end

  test "signed out user is redirected to sign in" do
    get items_path
    assert_redirected_to new_user_session_path
  end

  test "analyze_photo does not leak internal error details" do
    sign_in users(:alice)
    BackgroundRemoverService.stub(:call, ->(_photo) { raise RuntimeError, "secret internal detail" }) do
      post analyze_photo_items_path, params: { photo: fixture_file_upload("profile.png", "image/png") }
    end
    assert_response :unprocessable_entity
    assert_equal({ "error" => "Could not analyze photo" }, response.parsed_body)
    assert_not_includes response.body, "secret internal detail"
  end

  test "creating an item with status owned" do
    sign_in users(:alice)
    assert_difference "Item.count", 1 do
      post items_path, params: { item: item_attrs.merge(status: "owned") }
    end
    assert Item.order(:id).last.owned?
  end

  test "creating an item with status wishlist" do
    sign_in users(:alice)
    assert_difference "Item.count", 1 do
      post items_path, params: { item: item_attrs.merge(status: "wishlist") }
    end
    assert Item.order(:id).last.wishlist?
  end

  test "updating an item with a bogus status is a 422 and changes nothing" do
    sign_in users(:alice)
    item = items(:alice_top)
    patch item_path(item), params: { item: { status: "bogus" } }
    assert_response :unprocessable_entity
    assert item.reload.owned?
  end

  test "new redirects with the alert at the limit" do
    sign_in users(:alice)
    fill_closet(users(:alice))
    get new_item_path
    assert_redirected_to items_path
    assert_equal Item.limit_message, flash[:alert]
  end

  test "create at the limit redirects without calling the background remover" do
    sign_in users(:alice)
    fill_closet(users(:alice))
    BackgroundRemoverService.stub(:call, ->(_photo) { raise "paid call made" }) do
      assert_no_difference "Item.count" do
        post items_path, params: { item: item_attrs.merge(photo: fixture_file_upload("profile.png", "image/png")) }
      end
    end
    assert_redirected_to items_path
    assert_equal Item.limit_message, flash[:alert]
  end

  test "analyze_photo at the limit returns 422 without paid calls" do
    sign_in users(:alice)
    fill_closet(users(:alice))
    BackgroundRemoverService.stub(:call, ->(_photo) { raise "paid call made" }) do
      post analyze_photo_items_path, params: { photo: fixture_file_upload("profile.png", "image/png") }
    end
    assert_response :unprocessable_entity
    assert_equal({ "error" => Item.limit_message }, response.parsed_body)
  end

  test "closet page shows the user's item count only" do
    sign_in users(:alice)
    get items_path
    assert_includes response.body, "#{users(:alice).items.count} / 100 items"
    assert_not_includes response.body, "Closet full"
  end

  test "closet page shows the full line at the limit" do
    sign_in users(:alice)
    fill_closet(users(:alice))
    get items_path
    assert_includes response.body, "100 / 100 items"
    assert_includes response.body, "Closet full: delete an item to add a new one."
  end

  test "owner deletes an item and it leaves its outfits but the outfit and photo stay" do
    sign_in users(:alice)
    outfit = outfits(:alice_outfit)
    outfit.photo.attach(io: File.open(file_fixture("profile.png")), filename: "profile.png", content_type: "image/png")
    outfit.add_item!(items(:alice_bottom))
    assert_difference ["Item.count", "OutfitItem.count"], -1 do
      delete item_path(items(:alice_top))
    end
    assert_redirected_to items_path
    assert_response :see_other
    assert_equal "Item deleted.", flash[:notice]
    assert Outfit.exists?(outfit.id)
    assert_equal ["bottom"], outfit.reload.filled_slots
    assert outfit.photo.attached?
  end

  test "another user's item cannot be deleted" do
    sign_in users(:bob)
    assert_no_difference ["Item.count", "OutfitItem.count"] do
      delete item_path(items(:alice_top))
    end
    assert_response :not_found
  end

  test "signed out delete redirects to sign in" do
    assert_no_difference "Item.count" do
      delete item_path(items(:alice_top))
    end
    assert_redirected_to new_user_session_path
  end

  test "show confirm text includes the outfit count when the item is used" do
    sign_in users(:alice)
    get item_path(items(:alice_top))
    assert_includes response.body, "Delete this item? It&#39;s used in 1 outfit and will be removed from them."
  end

  test "show confirm text is plain when the item is unused" do
    sign_in users(:alice)
    get item_path(items(:alice_bottom))
    assert_includes response.body, "Delete this item?"
    assert_not_includes response.body, "used in"
  end

  private

  def item_attrs
    { name: "Hat", description: "A hat", category: "casual", slot: "top" }
  end
end
