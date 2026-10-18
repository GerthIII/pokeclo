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

  test "mark as bought with create_outfit_with_ai makes a draft outfit holding the item" do
    sign_in users(:alice)
    item = items(:alice_bottom)
    assert_difference "Outfit.count", 1 do
      patch mark_as_bought_item_path(item), params: { create_outfit_with_ai: true }
    end
    outfit = Outfit.order(:id).last
    assert_redirected_to edit_outfit_path(outfit, auto_ask: true)
    assert item.reload.owned?
    assert outfit.draft?
    assert_equal users(:alice), outfit.user
    assert_equal [item], outfit.items.to_a
  end

  test "mark as bought without the param redirects to the item and makes no outfit" do
    sign_in users(:alice)
    item = items(:alice_bottom)
    assert_no_difference "Outfit.count" do
      patch mark_as_bought_item_path(item)
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

  private

  def item_attrs
    { name: "Hat", description: "A hat", category: "casual", slot: "top" }
  end
end
