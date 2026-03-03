class Outfit < ApplicationRecord
  has_many :outfit_items
  has_many :items, through: :outfit_items
  has_many :messages
  belongs_to :user

  validates :name, presence: true
  validates :description, presence: true
  validates :status, presence: true
end
