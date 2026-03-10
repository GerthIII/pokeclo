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
end
