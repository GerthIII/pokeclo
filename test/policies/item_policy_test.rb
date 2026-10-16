require 'test_helper'

class ItemPolicyTest < ActiveSupport::TestCase
  def setup
    @alice = users(:alice)
    @bob = users(:bob)
    @alice_top = items(:alice_top)
  end

  def test_scope
    scope = ItemPolicy::Scope.new(@bob, Item).resolve
    assert_includes scope, items(:bob_top)
    assert_not_includes scope, @alice_top
    assert_not_includes scope, items(:alice_bottom)
  end

  def test_show
    assert ItemPolicy.new(@alice, @alice_top).show?
    assert_not ItemPolicy.new(@bob, @alice_top).show?
  end

  def test_create
    assert ItemPolicy.new(@alice, Item.new).create?
    assert_not ItemPolicy.new(nil, Item.new).create?
  end

  def test_update
    assert ItemPolicy.new(@alice, @alice_top).update?
    assert_not ItemPolicy.new(@bob, @alice_top).update?
  end

  def test_destroy
    assert ItemPolicy.new(@alice, @alice_top).destroy?
    assert_not ItemPolicy.new(@bob, @alice_top).destroy?
  end
end
