ActiveAdmin.register Genre do
  menu priority: 4, label: proc { t('active_admin.menus.genres') }

  breadcrumb do
    breadcrumbs(t('active_admin.menus.genres'), admin_genres_path)
  end

  actions :index

  config.sort_order = :name_asc
  config.filters = false

  index title: proc { t('active_admin.menus.genres') } do
    column :name
    column :books_count

    actions
  end
end
