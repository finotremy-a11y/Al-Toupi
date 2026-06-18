FactoryBot.define do
  factory :dish do
    association :dish_category
    sequence(:name) { |n| "Plat #{n}" }
    description { "Description du plat" }
    price { 12.5 }
    sequence(:position) { |n| n }

    trait :with_photo do
      after(:build) do |dish|
        next if dish.photo.attached?

        dish.photo.attach(
          io: File.open(Rails.root.join("public/icon.png")),
          filename: "icon.png",
          content_type: "image/png"
        )
      end
    end
  end
end
