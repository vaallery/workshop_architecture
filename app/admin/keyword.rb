ActiveAdmin.register Keyword do
  menu priority: 3, label: proc { t('active_admin.menus.keywords') }

  breadcrumb do
    breadcrumbs(t('active_admin.menus.keywords'), admin_keywords_path)
  end

  actions :index

  config.sort_order = :name_asc

  filter :name

  index title: proc { t('active_admin.menus.keywords') } do
    column :name
    column :books_count

    actions
  end
end
