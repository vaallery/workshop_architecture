class AdminUser < ApplicationRecord
  devise :database_authenticatable, :validatable
  validates :email, presence: true
end
