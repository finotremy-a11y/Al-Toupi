require "rails_helper"

RSpec.describe Photo, type: :model do
  describe "associations" do
    it "has one attached image" do
      photo = build(:photo)

      expect(photo.image).to be_a(ActiveStorage::Attached::One)
    end
  end

  describe "validations" do
    it "requires an attached image" do
      photo = build(:photo)
      photo.image.detach

      expect(photo).not_to be_valid
      expect(photo.errors[:image]).to be_present
    end
  end

  describe "scopes" do
    it "orders photos by ascending position" do
      late = create(:photo, position: 2)
      early = create(:photo, position: 1)

      expect(described_class.ordered).to eq([ early, late ])
    end

    it "returns first ordered photo as featured" do
      later = create(:photo, position: 3)
      earlier = create(:photo, position: 1)

      expect(described_class.featured).to eq(earlier)
      expect(described_class.featured).not_to eq(later)
    end
  end

  describe "active storage" do
    it "keeps an attached image after save" do
      photo = create(:photo)

      expect(photo.image).to be_attached
    end
  end
end
