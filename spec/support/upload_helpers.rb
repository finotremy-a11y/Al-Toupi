module UploadHelpers
  def fixture_upload(path: Rails.root.join("public/icon.png"), mime: "image/png")
    Rack::Test::UploadedFile.new(path, mime)
  end
end

RSpec.configure do |config|
  config.include UploadHelpers
end
