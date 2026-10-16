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

  test "owner can view their item" do
    sign_in users(:alice)
    get item_path(items(:alice_top))
    assert_response :success
  end

  test "signed out user is redirected to sign in" do
    get items_path
    assert_redirected_to new_user_session_path
  end
end
