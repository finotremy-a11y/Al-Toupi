class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: %i[new create]

  def new
    # Affiche le formulaire de connexion
  end

  def create
    admin = AdminUser.find_by(email: params[:email].to_s.strip.downcase)

    if admin&.authenticate(params[:password])
      session[:admin_user_id] = admin.id
      redirect_to admin_root_path, notice: "Bienvenue dans l'administration."
    else
      flash.now[:alert] = "Email ou mot de passe incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Vous avez été déconnecté."
  end

  private

  def redirect_if_logged_in
    redirect_to admin_root_path if admin_logged_in?
  end
end
