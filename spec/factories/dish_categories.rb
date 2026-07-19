FactoryBot.define do
  factory :dish_category do
    sequence(:name) { |n| "Categorie #{n}" }
    sequence(:position) { |n| n }
    category_type { :menu }

    trait :drinks do
      category_type { :drinks }
    end
  end
end
