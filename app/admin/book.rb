ActiveAdmin.register Book do
  menu priority: 1, label: proc { t('active_admin.menus.books') }

  breadcrumb do
    breadcrumbs(t('active_admin.menus.books'), admin_books_path)
  end

  actions :index, :show

  config.sort_order = :title_asc
  config.batch_actions = false

  filter :title
  filter :language_slug_eq,
         as: :select,
         label: I18n.t('active_admin.filters.language'),
         collection: proc { Language.pluck(:slug) }
  filter :genres_id_eq,
         as: :select,
         label: I18n.t('active_admin.filters.genre'),
         collection: proc {
           # TODO query + декоратор
           Genre.order(:name)
                .pluck(:name, :id)
                .map { |g| [ truncate(g.first, length: 25), g.last ] }
         }
  filter :keywords_id_eq,
         as: :select,
         label: I18n.t('active_admin.filters.keyword'),
         collection: proc {
           # TODO query + декоратор
           Keyword.order(:name)
                  .pluck(:name, :id)
                  .map { |k| [ truncate(k.first, length: 25), k.last ] }
         }

  controller do
    def scoped_collection
      super.includes(:genres, :authors, :language, :folder)
    end
  end

  FIO_FIELDS = %i[first_name last_name middle_name]

  member_action :download, method: :post do
    info = Books::ExtractService.call(id: params[:id])

    send_file info[:tempfile], type: 'application/octet-stream', filename: info[:filename]
  end

  index title: proc { t('active_admin.menus.books') } do
    column admin_i18n_t('books.columns.title') do |book|
      span link_to(book.title, admin_book_path(book.id))
      br
      br
      b admin_i18n_t('books.fields.authors')
      book.authors.map do |a|
        author = a.slice(*FIO_FIELDS).values.compact.join(' ')
        span link_to(author, admin_author_path(a.id))
      end.join(', ')
      br
      b admin_i18n_t('books.fields.file')
      span "#{book.folder.name}/#{book.filename}.#{book.ext}"
      br
      b admin_i18n_t('books.fields.published_at')
      span book.published_at
      br
      b admin_i18n_t('books.fields.genres')
      span book.genres.map(&:name).join(', ')
    end

    column admin_i18n_t('books.columns.download') do |book|
      button_to admin_i18n_t('buttons.download'), download_admin_book_path(book.id)
    end
  end

  show title: proc(&:title) do
    attributes_table title: proc(&:title) do
      row :title
      row admin_i18n_t('books.columns.authors') do |book|
        book.authors.map do |a|
          author = a.slice(*FIO_FIELDS).values.compact.join(' ')
          link_to(author, admin_author_path(a.id))
        end
      end
      row :size
      row(admin_i18n_t('books.columns.del')) { |book| book.del }
      row :filename do |book|
        "#{book.folder.name}/#{book.filename}.#{book.ext}"
      end
      row(admin_i18n_t('books.columns.published_at')) { |book| book.published_at }
      row(admin_i18n_t('books.columns.language')) { |book| book.language }
      row(admin_i18n_t('books.columns.genres')) do |book|
        book.genres.map do |g|
          params = { q: { genres_id_eq: g.id } }
          link_to(g.name, admin_books_path(params))
        end
      end
      row(admin_i18n_t('books.columns.keywords')) do |book|
        book.keywords.map do |k|
          params = { q: { keywords_id_eq: k.id } }
          link_to(k.name, admin_books_path(params))
        end
      end
    end

    panel admin_i18n_t('buttons.download') do
      render partial: 'form'
    end
  end
end
