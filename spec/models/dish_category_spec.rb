require "rails_helper"

RSpec.describe DishCategory, type: :model do
  describe "associations" do
    it "has many dishes" do
      category = create(:dish_category)
      dish = create(:dish, dish_category: category)

      expect(category.dishes).to include(dish)
    end

    it "destroys dependent dishes" do
      category = create(:dish_category)
      dish = create(:dish, dish_category: category)

      expect { category.destroy }.to change(Dish, :count).by(-1)
      expect { dish.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "validations" do
    it "requires a name" do
      category = build(:dish_category, name: nil)

      expect(category).not_to be_valid
      expect(category.errors[:name]).to be_present
    end

    it "defaults to menu category type" do
      category = create(:dish_category)

      expect(category).to be_menu
    end
  end

  describe "scopes" do
    it "orders categories by ascending position" do
      late = create(:dish_category, position: 9)
      early = create(:dish_category, position: 1)

      expect(described_class.ordered).to eq([ early, late ])
    end
  end
end
