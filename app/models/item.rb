class Item < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :outfits, through: :outfit_items
  has_one_attached :photo

  validates :category, presence: true
  validates :description, presence: true
  validates :name, presence: true
  validates :slot, presence: true
  SLOT = ['shirt', 'pants', 'shoes', 'jacket']
  # validates :status, presence: true
end
