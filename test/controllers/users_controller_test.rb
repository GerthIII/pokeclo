require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "dashboard shows only the signed-in user's items and outfits" do
    sign_in users(:bob)
    get dashboard_path
    assert_response :success
    assert_includes response.body, item_path(items(:bob_top))
    assert_not_includes response.body, item_path(items(:alice_top))
    assert_not_includes response.body, item_path(items(:alice_bottom))
    assert_includes response.body, outfit_path(outfits(:bob_outfit))
    assert_not_includes response.body, outfit_path(outfits(:alice_outfit))
  end
end
