require "rails_helper"

RSpec.describe MenuCard, type: :model do
  it "is valid with attached image" do
    menu_card = build(:menu_card)

    expect(menu_card).to be_valid
  end

  it "is invalid without file" do
    menu_card = MenuCard.new(title: "Carte")

    expect(menu_card).not_to be_valid
    expect(menu_card.errors[:file]).to be_present
  end

  it "accepts PDF upload" do
    menu_card = MenuCard.new(title: "Carte PDF")
    menu_card.file.attach(
      io: StringIO.new("%PDF-1.4 mock"),
      filename: "menu.pdf",
      content_type: "application/pdf"
    )

    expect(menu_card).to be_valid
  end

  it "rejects unsupported file types" do
    menu_card = MenuCard.new(title: "Carte")
    menu_card.file.attach(
      io: StringIO.new("text"),
      filename: "menu.txt",
      content_type: "text/plain"
    )

    expect(menu_card).not_to be_valid
    expect(menu_card.errors[:file]).to include("doit être une image (JPG, PNG, WEBP) ou un PDF")
  end
end
