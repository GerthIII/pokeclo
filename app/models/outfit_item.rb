class OutfitItem < ApplicationRecord
  belongs_to :item
  belongs_to :outfit

  validate :item_belongs_to_outfit_owner

  private

  def item_belongs_to_outfit_owner
    return if item.nil? || outfit.nil?

    errors.add(:item, "isn't in your closet") unless item.user_id == outfit.user_id
  end
end
