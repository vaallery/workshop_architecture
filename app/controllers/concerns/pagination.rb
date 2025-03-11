# frozen_string_literal: true

# Методы фильтрации сортировки и паджинации
module Pagination
  extend ActiveSupport::Concern
  # DEFAULT_LIMIT = Settings.app.items_per_page || 100

  def paginate(items)
    items.page(curr_page).per(limit)
  end

  def pagination_params
    { limit:, offset: }
  end

  private

  def curr_page
    @curr_page ||= params.fetch(:page, 1)
  end

  def limit
    @limit ||= params.fetch(:per_page, Settings.app.items_per_page || 100)
  end

  def offset
    @offset ||= limit * (curr_page - 1)
  end
end
