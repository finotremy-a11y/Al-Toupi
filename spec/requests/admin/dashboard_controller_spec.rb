require "rails_helper"

RSpec.describe "Admin::DashboardController", type: :request do
  it "redirects unauthenticated users to login" do
    get admin_root_path

    expect(response).to redirect_to(login_path)
  end

  it "allows authenticated admin users" do
    sign_in_admin

    get admin_root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Admin")
  end
end
