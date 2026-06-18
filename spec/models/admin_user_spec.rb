require "rails_helper"

RSpec.describe AdminUser, type: :model do
  describe "validations" do
    it "is valid with a unique and well-formed email" do
      user = build(:admin_user)

      expect(user).to be_valid
    end

    it "validates presence of email" do
      user = build(:admin_user, email: nil)

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "validates uniqueness of email" do
      create(:admin_user, email: "admin@example.com")
      duplicate = build(:admin_user, email: "admin@example.com")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it "validates email format" do
      user = build(:admin_user, email: "invalid-email")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "security" do
    it "uses has_secure_password" do
      user = create(:admin_user)

      expect(user.password_digest).to be_present
      expect(user.authenticate("password123")).to eq(user)
      expect(user.authenticate("bad-password")).to be(false)
    end

    it "requires a password on creation" do
      user = described_class.new(email: "new_admin@example.com")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end
end
