RSpec.describe 'Admin::KeywordsController', type: :feature do
  let(:user) { create(:admin_user) }
  let!(:keyword) { create(:keyword) }
  before(:each) { login(user) }

  it :index do
    visit admin_keywords_path
    expect(page).to have_content keyword.name
  end
end
