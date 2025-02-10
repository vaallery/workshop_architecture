RSpec.describe 'Admin::GenresController', type: :feature do
  let(:user) { create(:admin_user) }
  let!(:genre) { create(:genre) }
  before(:each) { login(user) }

  it :index do
    visit admin_genres_path
    expect(page).to have_content genre.name
  end
end
