ActiveAdmin.register Language do
  menu priority: 5, label: proc { t('active_admin.menus.languages') }

  breadcrumb do
    breadcrumbs(t('active_admin.menus.languages'), admin_languages_path)
  end

  actions :index

  config.sort_order = :slug_desc
  config.filters = false

  index title: proc { t('active_admin.menus.languages') } do
    column :slug
    column :name
    column :books_count

    actions
  end
end
