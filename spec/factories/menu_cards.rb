FactoryBot.define do
  factory :menu_card do
    title { "Carte du restaurant" }

    after(:build) do |menu_card|
      next if menu_card.file.attached?

      menu_card.file.attach(
        io: File.open(Rails.root.join("public/icon.png")),
        filename: "menu-card.png",
        content_type: "image/png"
      )
    end
  end
end
