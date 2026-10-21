require 'test_helper'

class OutfitPolicyTest < ActiveSupport::TestCase
  def setup
    @alice = users(:alice)
    @bob = users(:bob)
    @outfit = outfits(:alice_outfit)
  end

  def test_scope
    scope = OutfitPolicy::Scope.new(@bob, Outfit).resolve
    assert_includes scope, outfits(:bob_outfit)
    assert_not_includes scope, @outfit
  end

  def test_show
    assert OutfitPolicy.new(@alice, @outfit).show?
    assert_not OutfitPolicy.new(@bob, @outfit).show?
  end

  def test_create
    assert OutfitPolicy.new(@alice, Outfit.new).create?
    assert_not OutfitPolicy.new(nil, Outfit.new).create?
  end

  def test_clear_slot
    assert OutfitPolicy.new(@alice, @outfit).clear_slot?
    assert_not OutfitPolicy.new(@bob, @outfit).clear_slot?
  end

  def test_update
    assert OutfitPolicy.new(@alice, @outfit).update?
    assert_not OutfitPolicy.new(@bob, @outfit).update?
  end

  def test_try_on
    assert OutfitPolicy.new(@alice, @outfit).try_on?
    assert_not OutfitPolicy.new(@bob, @outfit).try_on?
  end

  def test_destroy
    assert OutfitPolicy.new(@alice, @outfit).destroy?
    assert_not OutfitPolicy.new(@bob, @outfit).destroy?
  end
end
