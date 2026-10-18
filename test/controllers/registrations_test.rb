require "test_helper"

class RegistrationsTest < ActionDispatch::IntegrationTest
  test "cancelling an account with items and outfits removes the user" do
    sign_in users(:alice)
    assert_difference "User.count", -1 do
      delete user_registration_path
    end
    assert_response :redirect
    assert_not User.exists?(users(:alice).id)
  end
end
