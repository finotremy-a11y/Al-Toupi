FactoryBot.define do
  factory :photo do
    sequence(:title) { |n| "Photo #{n}" }
    sequence(:position) { |n| n }

    after(:build) do |photo|
      next if photo.image.attached?

      photo.image.attach(
        io: File.open(Rails.root.join("public/icon.png")),
        filename: "icon.png",
        content_type: "image/png"
      )
    end
  end
end
