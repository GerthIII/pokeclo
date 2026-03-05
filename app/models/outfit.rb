class Outfit < ApplicationRecord
  attr_accessor :top_item_id, :bottom_item_id, :outer_item_id, :footwear_item_id

  has_many :outfit_items
  has_many :items, through: :outfit_items
  has_many :messages

  has_one_attached :jacket

  belongs_to :user

  validates :name, presence: true
  validates :description, presence: true
end
