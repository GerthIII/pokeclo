class Outfit < ApplicationRecord
  SLOTS = ['outer', 'top', 'bottom', 'footwear']
  has_many :outfit_items
  has_many :items, through: :outfit_items
  has_many :messages
  has_one_attached :image
  belongs_to :user

  validates :name, presence: true
  validates :description, presence: true
  validates :status, presence: true

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
