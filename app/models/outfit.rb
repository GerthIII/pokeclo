class Outfit < ApplicationRecord
  attr_accessor :top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id

  SLOTS = ['outer', 'top', 'bottom', 'footwear']
  has_many :outfit_items
  has_many :items, through: :outfit_items
  has_many :messages

  has_one_attached :photo

  belongs_to :user

  validates :name, presence: true

  def filled_slots
    items.pluck(:slot).compact.uniq
  end

  def missing_slots
    SLOTS - filled_slots
  end

  def candidate_items_for_missing_slots
    Item.where(user_id: user_id, slot: missing_slots)
  end

  # Backfills missing join-slot values using the item's own slot.
  # Useful for drafts created before slot was persisted on outfit_items.
  def normalize_outfit_item_slots!
    outfit_items.includes(:item).where(slot: [nil, ""]).find_each do |outfit_item|
      item_slot = outfit_item.item&.slot
      next if item_slot.blank?

      outfit_item.update!(slot: item_slot)
    end
  end
end
