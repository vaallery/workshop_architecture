class Genre < ApplicationRecord
  include Ransackable

  has_many :books_genres, dependent: :destroy
  has_many :books, through: :books_genres
  accepts_nested_attributes_for :books

  belongs_to :genre_group
  validates :slug, presence: true
  validates :slug, uniqueness: true

  PUBLIC_FIELDS = %w[id name updated_at created_at]
end
