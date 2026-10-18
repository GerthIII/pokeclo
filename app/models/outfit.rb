class Outfit < ApplicationRecord
  attr_accessor :top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id

  SLOTS = ['outer', 'top', 'bottom', 'footwear']
  # DECISION: dependent: :destroy (not :delete_all / DB cascade) so Active Storage callbacks
  #   also remove photos from Cloudinary instead of leaving orphaned files.
  #   Active Storage deletes files with a background job (purge_later), so this needs a job worker
  #   running in production.
  has_many :outfit_items, dependent: :destroy
  has_many :items, through: :outfit_items
  has_many :messages, dependent: :destroy
  # DECISION: Existing rows are 0 (the old code wrote "draft" into this integer column).
  #   default: :draft so outfits created from the form get a status too
  #   (rejected: allow_nil, which leaves new outfits with no status). Nothing sets :saved yet.
  enum :status, { draft: 0, saved: 1 }, default: :draft, validate: true

  has_one_attached :photo

  belongs_to :user

  validates :name, presence: true

  # DECISION: Slot item IDs come from the form, so we check they belong to this user.
  #   Also enforced on OutfitItem as a safety net for non-form paths (AI suggestions).
  validate :slot_items_belong_to_user

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

  private

  def slot_items_belong_to_user
    return if user.nil?

    ids = [top_item_id, bottom_item_id, outer_item_id, footwear_item_id].compact_blank.map(&:to_i).uniq
    return if ids.empty?

    errors.add(:base, "Those items aren't in your closet.") if user.items.where(id: ids).count != ids.size
  end
end
