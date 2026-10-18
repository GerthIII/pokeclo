require "test_helper"

class OutfitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @outfit = outfits(:alice_outfit)
    users(:alice).profile_photo.attach(
      io: File.open(file_fixture("profile.png")), filename: "profile.png", content_type: "image/png"
    )
  end

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
      post try_on_outfit_path(@outfit)
    end
    assert_response :not_found
  end

  test "try_on no longer routes for GET" do
    sign_in users(:alice)
    get "/outfits/#{@outfit.id}/try_on"
    assert_response :not_found
  end

  test "try_on without a profile photo redirects with an alert" do
    users(:alice).profile_photo.purge
    sign_in users(:alice)
    post try_on_outfit_path(@outfit)
    assert_response :see_other
    assert_redirected_to edit_user_registration_path
    assert_equal "Add a profile photo to try outfits on.", flash[:alert]
  end

  test "try_on attaches the photo and redirects with 303" do
    sign_in users(:alice)
    GeminiService.stub(:generate_try_on, ->(**) { StringIO.new("img") }) do
      post try_on_outfit_path(@outfit)
    end
    assert_response :see_other
    assert_redirected_to outfit_path(@outfit)
    assert @outfit.reload.photo.attached?
  end

  test "try_on retries a retryable error once, then redirects with an alert" do
    sign_in users(:alice)
    calls = 0
    GeminiService.stub(:generate_try_on, ->(**) { calls += 1; raise RubyLLM::ServerError.new(nil, "boom") }) do
      post try_on_outfit_path(@outfit)
    end
    assert_equal 2, calls
    assert_response :see_other
    assert_redirected_to outfit_path(@outfit)
    assert_equal "OOPS, something went wrong. Please try again.", flash[:alert]
  end

  test "try_on does not retry other errors" do
    sign_in users(:alice)
    calls = 0
    GeminiService.stub(:generate_try_on, ->(**) { calls += 1; raise ArgumentError }) do
      post try_on_outfit_path(@outfit)
    end
    assert_equal 1, calls
    assert_redirected_to outfit_path(@outfit)
    assert_equal "OOPS, something went wrong. Please try again.", flash[:alert]
  end

  test "owner can view their outfit" do
    sign_in users(:alice)
    get outfit_path(@outfit)
    assert_response :success
  end

  test "owner cannot put another user's item into an outfit" do
    sign_in users(:alice)
    assert_no_difference "OutfitItem.count" do
      patch outfit_path(@outfit), params: { outfit: { name: "Alice's Outfit", top_item_id: items(:bob_top).id } }
    end
    assert_response :unprocessable_entity
    assert_equal [items(:alice_top)], @outfit.reload.items.to_a
  end

  test "owner cannot create an outfit with another user's item" do
    sign_in users(:alice)
    assert_no_difference ["Outfit.count", "OutfitItem.count"] do
      post outfits_path, params: { outfit: { name: "Sneaky", top_item_id: items(:bob_top).id } }
    end
    assert_response :unprocessable_entity
  end

  test "owner can update an outfit with their own item" do
    sign_in users(:alice)
    patch outfit_path(@outfit), params: { outfit: { name: "Renamed", top_item_id: items(:alice_top).id } }
    assert_redirected_to outfit_path(@outfit)
    assert_equal "Renamed", @outfit.reload.name
    assert_equal [items(:alice_top)], @outfit.items.to_a
  end

  test "owner can create an outfit with their own item" do
    sign_in users(:alice)
    assert_difference ["Outfit.count", "OutfitItem.count"], 1 do
      post outfits_path, params: { outfit: { name: "Fresh", top_item_id: items(:alice_top).id } }
    end
    assert_redirected_to outfit_path(Outfit.find_by!(name: "Fresh"))
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
