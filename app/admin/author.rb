ActiveAdmin.register Author do
  menu priority: 2, label: proc { t('active_admin.menus.authors') }

  breadcrumb do
    breadcrumbs(t('active_admin.menus.authors'), admin_authors_path)
  end

  actions :index, :show

  config.sort_order = :last_name_asc

  filter :original

  index title: proc { t('active_admin.menus.authors') } do
    column :first_name
    column :last_name
    column :middle_name
    column :books_count

    actions
  end

  show title: proc { |user| user.slice(*FIO_FIELDS).values.compact.join(' ') } do
    attributes_table do
      row :first_name
      row :last_name
      row :middle_name
    end

    panel admin_i18n_t('authors.title') do
      scope = resource.books.includes(:authors, :genres, :folder, :language).order(title: :desc)
      table_for scope do
        column admin_i18n_t('authors.columns.title') do |book|
          span link_to(book.title, admin_book_path(book.id))
          br
          br
          b admin_i18n_t('authors.fields.authors')
          book.authors.map do |a|
            author = a.slice(*FIO_FIELDS).values.compact.join(' ')
            span link_to(author, admin_author_path(a.id))
          end.join(', ')
          br
          b admin_i18n_t('authors.fields.file')
          span "#{book.folder.name}/#{book.filename}.#{book.ext}"
          br
          b admin_i18n_t('authors.fields.published_at')
          span book.published_at
          br
          b admin_i18n_t('authors.fields.genres')
          span book.genres.map(&:name).join(', ')
          br
          b admin_i18n_t('authors.fields.language')
          span book.language.name
        end
        column admin_i18n_t('authors.columns.action') do |book|
          button_to admin_i18n_t('buttons.download'), download_admin_book_path(book.id)
        end
      end
    end
  end
end
