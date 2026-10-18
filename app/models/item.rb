class Item < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :outfits, through: :outfit_items
  has_one_attached :photo
  before_validation :set_default_status, on: :create

  validates :category, presence: true
  validates :description, presence: true
  validates :name, presence: true
  validates :slot, presence: true
  SLOT = ['outer', 'top', 'bottom', 'footwear']
  CATEGORY = ['sports', 'casual', 'formal', 'outdoor']
  # DECISION: Named enum over raw integers. Numbers unchanged (1 = owned, 2 = wishlist), so no migration.
  #   validate: true turns a bad value into a form error instead of a 500.
  enum :status, { owned: 1, wishlist: 2 }, validate: true

  private

  def set_default_status
    self.status ||= :wishlist
  end
end
