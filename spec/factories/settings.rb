FactoryBot.define do
  factory :setting do
    sequence(:key) { |n| "key_#{n}" }
    value { "Valeur" }
  end
end
