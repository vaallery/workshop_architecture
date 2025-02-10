module ActiveAdmin
  module LocaleHelper
    def admin_i18n_t(key)
      I18n.t("active_admin.custom.panels.#{key}")
    end

    def breadcrumbs(page_title, page_path)
      [
        link_to(t('active_admin.menus.admin'), admin_root_path),
        link_to(page_title, page_path)
      ]
    end
  end
end
