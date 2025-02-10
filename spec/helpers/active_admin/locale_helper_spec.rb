describe ActiveAdmin::LocaleHelper, type: :helper do
  describe '#admin_i18n_t' do
    it 'возвращает корректные переводы для книг' do
      expect(helper.admin_i18n_t('books.columns.title')).to eq('Книга')
      expect(helper.admin_i18n_t('books.columns.authors')).to eq('Авторы')
      expect(helper.admin_i18n_t('books.columns.language')).to eq('Язык')
      expect(helper.admin_i18n_t('books.columns.filename')).to eq('Файл')
      expect(helper.admin_i18n_t('books.columns.download')).to eq('Скачать')
    end
  end
end
