class Language < ApplicationRecord
  include Ransackable

  has_many :books, dependent: :destroy

  validates :slug, presence: true
  validates :slug, uniqueness: true

  PUBLIC_FIELDS = %w[slug name created_at updated_at]
  RANSACK_ASSOCIATIONS = []
end
