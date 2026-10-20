require 'test_helper'

class MessagePolicyTest < ActiveSupport::TestCase
  def setup
    @alice = users(:alice)
    @bob = users(:bob)
    @message = outfits(:alice_outfit).messages.build(content: "hi")
  end

  def test_scope
    scope = MessagePolicy::Scope.new(@bob, Message).resolve
    assert_not_includes scope, messages(:alice_user_message)
    assert_not_includes scope, messages(:alice_assistant_message)
    assert_includes MessagePolicy::Scope.new(@alice, Message).resolve, messages(:alice_user_message)
  end

  def test_create
    assert MessagePolicy.new(@alice, @message).create?
    assert_not MessagePolicy.new(@bob, @message).create?
  end

  def test_change_slot
    assert MessagePolicy.new(@alice, messages(:alice_assistant_message)).change_slot?
    assert_not MessagePolicy.new(@bob, messages(:alice_assistant_message)).change_slot?
  end
end
