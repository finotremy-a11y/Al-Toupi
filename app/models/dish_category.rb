class DishCategory < ApplicationRecord
  has_many :dishes, dependent: :destroy

  enum :category_type, { menu: 0, drinks: 1 }

  validates :name, presence: true
  validates :category_type, presence: true

  scope :ordered, -> { order(position: :asc) }
end
