class Admin::SettingsController < Admin::BaseController
  before_action :set_setting, only: %i[edit update destroy]

  def index
    @settings = Setting.ordered
  end

  def new
    @setting = Setting.new(key: params[:key])
  end

  def create
    @setting = Setting.new(setting_params)
    if @setting.save
      redirect_to admin_settings_path, notice: "Paramètre créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @setting.update(setting_params)
      redirect_to admin_settings_path, notice: "Paramètre mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @setting.destroy
    redirect_to admin_settings_path, notice: "Paramètre supprimé."
  end

  private

  def set_setting
    @setting = Setting.find(params[:id])
  end

  def setting_params
    params.require(:setting).permit(:key, :value)
  end
end
