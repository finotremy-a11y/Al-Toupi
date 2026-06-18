module AuthHelpers
  def sign_in_admin(admin = create(:admin_user))
    post login_path, params: { email: admin.email, password: "password123" }
    admin
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
