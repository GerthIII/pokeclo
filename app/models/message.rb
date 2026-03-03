class Message < ApplicationRecord
  belongs_to :outfit

  validates :role, presence: true
  validates :content, presence: true
end
