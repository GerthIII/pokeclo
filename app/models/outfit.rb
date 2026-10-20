class Outfit < ApplicationRecord
  attr_accessor :top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id

  SLOTS = ['outer', 'top', 'bottom', 'footwear']
  SLOT_ITEM_ATTRS = SLOTS.map { |slot| "#{slot}_item_id" }.freeze
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

  def apply_suggestions!(suggestions)
    suggestions.each do |suggestion|
      item = user.items.find_by(id: suggestion["item_id"])
      slot = suggestion["slot"]
      next if item.nil? || slot.blank?

      assign_slot!(slot, item)
    end
  end

  # Creates an outfit_item for each present *_item_id virtual attribute. Raises on invalid rows.
  def create_slot_items!
    SLOTS.each do |slot|
      item_id = public_send("#{slot}_item_id")
      outfit_items.create!(item_id: item_id, slot: slot) if item_id.present?
    end
  end

  # Saves attributes and slot items all-or-nothing. Returns true, or false with errors on self.
  def save_with_slot_items(params)
    # DECISION: Save outfit + its items all-or-nothing so a failure can't leave a half-empty outfit.
    SLOTS.each { |slot| public_send("#{slot}_item_id=", params["#{slot}_item_id"]) }
    transaction do
      raise ActiveRecord::Rollback unless update(params.except(*SLOT_ITEM_ATTRS))

      outfit_items.destroy_all
      create_slot_items!
      true
    end || false
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.full_messages.each { |message| errors.add(:base, message) }
    false
  end

  def hydrate_slot_item_ids!
    slot_item_ids = outfit_items.pluck(:slot, :item_id).to_h
    SLOTS.each { |slot| public_send("#{slot}_item_id=", slot_item_ids[slot]) }
  end

  def assign_slot_item(item)
    public_send("#{item.slot}_item_id=", item.id) if SLOTS.include?(item.slot)
  end

  # Returns [message, { slot => item_id }] for the newest assistant message holding a usable
  # suggestion array, or [nil, {}].
  def latest_suggestion
    messages.where(role: "assistant").order(created_at: :desc).each do |message|
      slot_item_ids = suggestion_slot_item_ids(message)
      return [message, slot_item_ids] if slot_item_ids.present?
    end
    [nil, {}]
  end

  private

  def suggestion_slot_item_ids(message)
    parsed = JSON.parse(message.content)
    parsed.is_a?(Array) ? slot_item_ids_from(parsed) : {}
  rescue JSON::ParserError
    {}
  end

  def slot_item_ids_from(entries)
    entries.grep(Hash).each_with_object({}) do |entry, ids|
      slot = entry["slot"].to_s
      item_id = entry["item_id"].to_i
      ids[slot] = item_id unless slot.blank? || item_id.zero?
    end
  end

  def assign_slot!(slot, item)
    outfit_item = outfit_items.find_or_initialize_by(slot: slot)
    outfit_item.item = item
    outfit_item.save!
    outfit_items.where(slot: slot).where.not(id: outfit_item.id).delete_all
  end

  def slot_items_belong_to_user
    return if user.nil?

    ids = [top_item_id, bottom_item_id, outer_item_id, footwear_item_id].compact_blank.map(&:to_i).uniq
    return if ids.empty?

    errors.add(:base, "Those items aren't in your closet.") if user.items.where(id: ids).count != ids.size
  end
end
