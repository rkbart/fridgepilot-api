class Recipe < ApplicationRecord
  belongs_to :user
  has_many :grocery_items, dependent: :destroy

  validates :name, presence: true
  validates :ingredients, presence: true
  validate :ingredients_must_be_array

  private

  def ingredients_must_be_array
    return if ingredients.is_a?(Array)
    errors.add(:ingredients, "must be an array")
  end
end
