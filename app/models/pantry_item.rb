class PantryItem < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }, if: -> { name.present? }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :normalize_name

  private

  def normalize_name
    return if name.nil?

    self.name = name.strip.gsub(/\s+/, " ")
  end
end
