module ApplicationHelper
  # Retourne la valeur d'un Setting par sa clé, ou une valeur par défaut
  def setting_value(key, default = nil)
    Setting.get(key) || default
  end
end
