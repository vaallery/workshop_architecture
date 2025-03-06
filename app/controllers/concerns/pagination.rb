# frozen_string_literal: true

# Методы фильтрации сортировки и паджинации
module Pagination
  extend ActiveSupport::Concern
  # DEFAULT_LIMIT = Settings.app.items_per_page || 100

  def paginate(items)
    curr_page = params[:page] || 1
    limit = params[:per_page] || Settings.app.items_per_page || 100
    items.page(curr_page).per(limit)
  end
end
