class Admin::MenuCardsController < Admin::BaseController
  def show
    @menu_card = MenuCard.first_or_initialize
  end

  def update
    @menu_card = MenuCard.first_or_initialize

    if @menu_card.update(menu_card_params)
      redirect_to admin_menu_card_path, notice: "Carte mise à jour avec succès."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    menu_card = MenuCard.first

    if menu_card.present?
      menu_card.destroy
      redirect_to admin_menu_card_path, notice: "Carte supprimée. Retour à la carte manuelle activé."
    else
      redirect_to admin_menu_card_path, alert: "Aucune carte à supprimer."
    end
  end

  private

  def menu_card_params
    params.require(:menu_card).permit(:title, :file)
  end
end
