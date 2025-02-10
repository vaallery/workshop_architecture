RSpec.describe 'Admin::AuthorsController', type: :feature do
  let(:user) { create(:admin_user) }
  let!(:author) { create(:author_with_books) }
  before(:each) { login(user) }

  it :index do
    visit admin_authors_path
    expect(page).to have_content author.last_name
  end

  it :show do
    visit admin_author_path(author)
    expect(page).to have_content author.last_name
  end
end
