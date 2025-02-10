class GenreGroup < ApplicationRecord
  has_many :genres, inverse_of: :genre_group, dependent: :destroy
  accepts_nested_attributes_for :genres, allow_destroy: true

  validates :name, presence: true
  validates :name, uniqueness: true
end
