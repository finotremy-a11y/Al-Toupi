require "rails_helper"

RSpec.describe Dish, type: :model do
  describe "associations" do
    it "belongs to a dish category" do
      category = create(:dish_category)
      dish = create(:dish, dish_category: category)

      expect(dish.dish_category).to eq(category)
    end

    it "has one attached photo" do
      dish = build(:dish)

      expect(dish.photo).to be_a(ActiveStorage::Attached::One)
    end
  end

  describe "validations" do
    it "requires name, price and dish_category" do
      dish = build(:dish, name: nil, price: nil, dish_category: nil)

      expect(dish).not_to be_valid
      expect(dish.errors[:name]).to be_present
      expect(dish.errors[:price]).to be_present
      expect(dish.errors[:dish_category]).to be_present
    end

    it "requires a positive price" do
      dish = build(:dish, price: 0)

      expect(dish).not_to be_valid
      expect(dish.errors[:price]).to be_present
    end
  end

  describe "scopes" do
    it "orders dishes by ascending position" do
      late = create(:dish, position: 5)
      early = create(:dish, position: 2)

      expect(described_class.ordered).to eq([ early, late ])
    end
  end

  describe "active storage" do
    it "supports attaching a photo" do
      dish = create(:dish)

      expect(dish.photo).not_to be_attached

      dish.photo.attach(
        io: File.open(Rails.root.join("public/icon.png")),
        filename: "icon.png",
        content_type: "image/png"
      )

      expect(dish.photo).to be_attached
    end
  end
end
