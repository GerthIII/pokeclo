class OutfitItem < ApplicationRecord
  belongs_to :item
  belongs_to :outfit

  validates :slot, presence: true
end
