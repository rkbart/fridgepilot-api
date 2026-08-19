class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  has_many :recipes, dependent: :destroy
  has_many :pantry_items, dependent: :destroy
  has_many :grocery_lists, dependent: :destroy
end
