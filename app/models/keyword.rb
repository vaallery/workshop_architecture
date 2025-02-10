class Keyword < ApplicationRecord
  include Ransackable

  has_many :books_keywords, dependent: :destroy
  has_many :books, through: :books_keywords
  accepts_nested_attributes_for :books

  validates :name, presence: true
  validates :name, uniqueness: true

  PUBLIC_FIELDS = %w[id name created_at updated_at]
  RANSACK_ASSOCIATIONS = []
end
