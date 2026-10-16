require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixtures load and alice is valid" do
    assert users(:alice).valid?
  end
end
