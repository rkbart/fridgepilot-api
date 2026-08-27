class GroceryList < ApplicationRecord
  belongs_to :user
  has_many :grocery_items, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false, message: "already exists" }
  validates :source, inclusion: { in: %w[manual ai_generated] }
  validates :status, inclusion: { in: %w[active archived] }

  scope :active, -> { where(status: "active") }
  scope :archived, -> { where(status: "archived") }

  after_initialize :set_default_source, if: :new_record?

  private

  def set_default_source
    self.source ||= "manual"
  end
end
