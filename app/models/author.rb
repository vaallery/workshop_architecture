class Author < ApplicationRecord
  include Ransackable

  has_many :books_authors, dependent: :destroy
  has_many :books, through: :books_authors
  accepts_nested_attributes_for :books

  validates :first_name, presence: true
  validates :first_name, uniqueness: { scope: %i[last_name middle_name original] }

  PUBLIC_FIELDS = %w[first_name id id_value last_name middle_name original created_at updated_at]
  RANSACK_ASSOCIATIONS = []
end
