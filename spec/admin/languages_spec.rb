RSpec.describe 'Admin::LanguagesController', type: :feature do
  let(:user) { create(:admin_user) }
  let!(:language) { create(:language) }
  before(:each) { login(user) }

  it :index do
    visit admin_languages_path
    expect(page).to have_content language.slug
  end
end
