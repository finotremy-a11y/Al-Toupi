class MenuCard < ApplicationRecord
  has_one_attached :file

  validates :title, presence: true
  validates :file, presence: true
  validate :acceptable_file_type

  def image?
    file.attached? && file.content_type&.start_with?("image/")
  end

  private

  def acceptable_file_type
    return unless file.attached?

    allowed = [ "image/jpeg", "image/png", "image/webp", "application/pdf" ]
    return if allowed.include?(file.content_type)

    errors.add(:file, "doit être une image (JPG, PNG, WEBP) ou un PDF")
  end
end
