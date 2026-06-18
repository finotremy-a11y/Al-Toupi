require "rails_helper"

RSpec.describe Setting, type: :model do
  describe "validations" do
    it "requires key presence" do
      setting = build(:setting, key: nil)

      expect(setting).not_to be_valid
      expect(setting.errors[:key]).to be_present
    end

    it "requires key uniqueness" do
      create(:setting, key: "site_title")
      duplicate = build(:setting, key: "site_title")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:key]).to be_present
    end
  end

  describe "scopes" do
    it "orders settings by key ascending" do
      zeta = create(:setting, key: "zeta")
      alpha = create(:setting, key: "alpha")

      expect(described_class.ordered).to eq([ alpha, zeta ])
    end
  end

  describe ".get" do
    it "returns stored value" do
      create(:setting, key: "telephone", value: "01 02 03 04 05")

      expect(described_class.get("telephone")).to eq("01 02 03 04 05")
    end

    it "returns nil when key is missing" do
      expect(described_class.get("missing")).to be_nil
    end
  end

  describe ".set" do
    it "creates a new setting when key is missing" do
      expect { described_class.set("adresse", "Salles-Curan") }.to change(described_class, :count).by(1)
      expect(described_class.get("adresse")).to eq("Salles-Curan")
    end

    it "updates an existing setting" do
      create(:setting, key: "adresse", value: "Ancienne")

      expect { described_class.set("adresse", "Nouvelle") }.not_to change(described_class, :count)
      expect(described_class.get("adresse")).to eq("Nouvelle")
    end
  end
end
