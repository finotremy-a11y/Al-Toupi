FactoryBot.define do
  factory :dish_category do
    sequence(:name) { |n| "Categorie #{n}" }
    sequence(:position) { |n| n }
  end
end
