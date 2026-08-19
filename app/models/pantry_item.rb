class PantryItem < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
