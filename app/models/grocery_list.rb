class GroceryList < ApplicationRecord
  belongs_to :user
  has_many :grocery_items, dependent: :destroy

  validates :source, inclusion: { in: %w[manual ai_generated] }

  after_initialize :set_default_source, if: :new_record?

  private

  def set_default_source
    self.source ||= "manual"
  end
end
