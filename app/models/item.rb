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

  # DECISION: Cap of 100 items per user, closet and wishlist together.
  #   100 keeps the AI prompt small (about 120 tokens per item, so about 12k tokens; a few hundred would push
  #   chat replies toward Heroku's 30 s timeout). Wishlist counts because the AI receives those items too.
  #   Rejected: no cap.
  #   Rejected: counting only closet items (Mark as bought would also need blocking at 100).
  MAX_PER_USER = 100
  validate :within_item_limit, on: :create

  def self.limit_reached_for?(user)
    where(user_id: user.id).count >= MAX_PER_USER
  end

  def self.limit_message
    "You can have at most #{MAX_PER_USER} items. Delete one to add another."
  end

  private

  def set_default_status
    self.status ||= :wishlist
  end

  def within_item_limit
    errors.add(:base, self.class.limit_message) if user && self.class.limit_reached_for?(user)
  end
end
