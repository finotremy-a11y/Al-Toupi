class DishCategory < ApplicationRecord
  has_many :dishes, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(position: :asc) }
end
