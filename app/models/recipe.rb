class Recipe < ApplicationRecord
  belongs_to :user
  has_many :grocery_items, dependent: :destroy

  validates :name, presence: true
  validate :ingredients_must_be_valid
  validate :instructions_must_be_valid

  private

  def ingredients_must_be_valid
    return if ingredients.is_a?(Array) && ingredients.all? { |i| i.is_a?(Hash) && i["name"].present? }
    errors.add(:ingredients, "must be a list of items with a name")
  end

  def instructions_must_be_valid
    return if instructions.nil?
    return if instructions.is_a?(Array) && instructions.all? { |s| s.is_a?(String) }
    errors.add(:instructions, "must be a list of steps")
  end
end
