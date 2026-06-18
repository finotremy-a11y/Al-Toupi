class Photo < ApplicationRecord
  has_one_attached :image

  validates :image, presence: true

  scope :ordered, -> { order(position: :asc) }

  def self.featured
    ordered.first
  end
end
