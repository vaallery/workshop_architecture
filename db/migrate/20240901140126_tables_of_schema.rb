class TablesOfSchema < ActiveRecord::Migration[7.2]
  enable_extension 'pgcrypto'

  def change
    create_table :authors, id: :uuid, comment: 'Авторы книг', force: :cascade do |t|
      t.timestamps

      t.string :first_name, null: false, comment: 'Имя автора'
      t.string :last_name, comment: 'Фамилия автора'
      t.string :middle_name, comment: 'Отчество автора'
      t.string :original, comment: 'Автор в inpx-индексе'
      t.integer :books_count, default: 0, null: false, comment: "Количество книг"
      t.index %i[first_name last_name middle_name original], name: :idx_on_first_name_last_name_middle_name_original_8ed0e1cb00, unique: true
    end

    create_table :genre_groups, id: :uuid, comment: 'Группа жанров книг', force: :cascade do |t|
      t.timestamps

      t.string :name, null: false, comment: 'Название группы жанра'
      t.index :name, name: :index_genre_groups_on_name, unique: true
    end

    create_table :genres, id: :uuid, comment: 'Жанры книг', force: :cascade do |t|
      t.timestamps

      t.string :slug, null: false, comment: 'Обозначение жанра в библиотеке'
      t.string :name, null: true, comment: 'Название жанра'
      t.references :genre_group, type: :uuid, index: true, foreign_key: true, null: false
      t.integer :books_count, default: 0, null: false, comment: "Количество книг"
      t.index :slug, name: :index_genres_on_slug, unique: true
    end

    create_table :keywords, id: :uuid, comment: 'Ключевые слова', force: :cascade do |t|
      t.timestamps

      t.string :name, null: false, comment: 'Ключевое слово'
      t.integer :books_count, default: 0, null: false, comment: "Количество книг"
      t.index :name, name: :index_keywords_on_name, unique: true
    end

    create_table :languages, id: :uuid, comment: 'Языки книг', force: :cascade do |t|
      t.timestamps

      t.string :slug, null: false, comment: 'Обозначение языка'
      t.string :name, null: true, comment: 'Название языка'
      t.integer :books_count, default: 0, null: false, comment: "Количество книг"
      t.index :slug, name: :index_languages_on_slug, unique: true
    end

    create_table :folders, id: :uuid, comment: 'Папки книг', force: :cascade do |t|
      t.timestamps

      t.string :name, null: false, comment: 'Название папки'
      t.index :name, name: :index_folders_on_name, unique: true
    end

    create_table :books, id: :uuid, comment: 'Книги', force: :cascade do |t|
      t.timestamps

      t.string :title, null: false, comment: 'Название'
      t.string :series, null: true, comment: 'Серия'
      t.string :serno, null: true, comment: 'Номер в серии'
      t.integer :libid, null: false, comment: 'Идентификатор книги в библиотеке'
      t.integer :size, null: false, comment: 'Размер файла в байтах'
      t.integer :filename, null: false, comment: 'Название файла в архиве'
      t.boolean :del, null: false, default: false, comment: 'Удален ли файл из библиотеки'
      t.string :ext, null: false, default: 'fb2', comment: 'Расширение файла'
      t.date :published_at, null: true, comment: 'Дата публикации файла в библиотеке'
      t.string :insno, null: true, comment: 'ISBN'
      t.references :folder, type: :uuid, index: true, foreign_key: true, null: false
      t.references :language, type: :uuid, index: true, foreign_key: true, null: false
      t.index %i[folder_id libid], name: :idx_on_folder_id_libid, unique: true
    end

    create_table :books_authors, id: :uuid, comment: 'Связь книги с авторами', force: :cascade do |t|
      t.timestamps
      t.references :book, type: :uuid, index: true, foreign_key: true, null: false
      t.references :author, type: :uuid, index: true, foreign_key: true, null: false
    end

    create_table :books_genres, id: :uuid, comment: 'Связь книги с жанрами', force: :cascade do |t|
      t.timestamps
      t.references :book, type: :uuid, index: true, foreign_key: true, null: false
      t.references :genre, type: :uuid, index: true, foreign_key: true, null: false
    end

    create_table :books_keywords, id: :uuid, comment: 'Связь книги с ключевыми словами', force: :cascade do |t|
      t.timestamps
      t.references :book, type: :uuid, index: true, foreign_key: true, null: false
      t.references :keyword, type: :uuid, index: true, foreign_key: true, null: false
    end

    create_table :admin_users, id: :uuid, comment: 'Учетные записи для системы администрирования', force: :cascade do |t|
      t.timestamps null: false
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.index :email, name: :index_admin_users_on_email, unique: true
    end
  end
end
