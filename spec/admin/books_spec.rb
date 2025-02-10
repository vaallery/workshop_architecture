RSpec.describe 'Admin::BooksController', type: :feature do
  let(:user) { create(:admin_user) }
  let!(:book) { create(:book_with_authors) }
  before(:each) { login(user) }

  context 'на главной странице' do
    it :index do
      visit admin_books_path
      expect(page).to have_content book.title
    end

    it :download do
      visit admin_books_path
      click_button 'Скачать'
      expect(page).to have_content '3064'
    end
  end

  context 'на детальной странице' do
    it :show do
      visit admin_book_path(book)
      expect(page).to have_content book.title
    end

    it :download do
      visit admin_book_path(book)
      click_button 'Скачать'
      expect(page).to have_content '3064'
    end
  end
end
