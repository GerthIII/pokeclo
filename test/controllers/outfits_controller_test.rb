require "test_helper"

class OutfitsControllerTest < ActionDispatch::IntegrationTest
  setup { @outfit = outfits(:alice_outfit) }

  test "another user's outfit show is a 404" do
    sign_in users(:bob)
    get outfit_path(@outfit)
    assert_response :not_found
  end

  test "another user's outfit edit is a 404" do
    sign_in users(:bob)
    get edit_outfit_path(@outfit)
    assert_response :not_found
  end

  test "another user's outfit cannot be updated" do
    sign_in users(:bob)
    assert_no_changes -> { @outfit.reload.attributes } do
      patch outfit_path(@outfit), params: { outfit: { name: "hacked" } }
    end
    assert_response :not_found
    assert_equal "Alice's Outfit", @outfit.reload.name
  end

  test "another user's outfit chat is a 404" do
    sign_in users(:bob)
    get chat_outfit_path(@outfit)
    assert_response :not_found
  end

  test "another user's outfit cannot be tried on" do
    sign_in users(:bob)
    assert_no_changes -> { @outfit.reload.photo.attached? } do
      get try_on_outfit_path(@outfit)
    end
    assert_response :not_found
  end

  test "owner can view their outfit" do
    sign_in users(:alice)
    get outfit_path(@outfit)
    assert_response :success
  end

  # Without the fix this raises (the Disk service cannot build a photo URL in tests), which is how it fails.
  test "AI suggestion pointing at another user's item does not show that item's photo" do
    bob_top = items(:bob_top)
    bob_top.photo.attach(io: StringIO.new("img"), filename: "bob.png", content_type: "image/png")
    messages(:alice_assistant_message).update!(
      content: [{ item_id: bob_top.id, slot: "top", item_name: "Mystery" }].to_json
    )
    sign_in users(:alice)
    get edit_outfit_path(@outfit)
    assert_response :success
    assert_includes response.body, "Mystery"
    assert_not_includes response.body, "bob.png"
    assert_not_includes response.body, "Bob's Black Tee"
    assert_no_match(/<img[^>]*width="80"/, response.body)
  end
end
