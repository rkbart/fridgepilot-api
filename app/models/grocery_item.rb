class GroceryItem < ApplicationRecord
  belongs_to :recipe, optional: true
  belongs_to :grocery_list

  validates :name, presence: true
  validates :status, inclusion: { in: %w[pending confirmed checked] }
  validates :source, inclusion: { in: %w[manual ai_suggested] }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.status ||= "pending"
    self.source ||= "manual"
  end
end
