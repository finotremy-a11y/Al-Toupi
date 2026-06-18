module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_admin_user, :admin_logged_in?
  end

  def current_admin_user
    @current_admin_user ||= AdminUser.find_by(id: session[:admin_user_id])
  end

  def admin_logged_in?
    current_admin_user.present?
  end

  def require_admin
    unless admin_logged_in?
      redirect_to login_path, alert: "Veuillez vous connecter pour accéder à l'administration."
    end
  end
end
