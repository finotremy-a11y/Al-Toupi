class Dish < ApplicationRecord
  belongs_to :dish_category
  has_one_attached :photo

  validates :name, :price, presence: true
  validates :dish_category, presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :ordered, -> { order(position: :asc) }
end
