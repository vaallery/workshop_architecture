describe 'Система администрирования', type: :feature do
  let(:user) { create(:admin_user) }

  it 'успешный вход' do
    visit new_admin_user_session_path
    within('#new_admin_user') do
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
    end
    click_button 'Войти'
    expect(page).to have_content 'Административная панель'
  end

  it 'успешный выход' do
    login(user)
    visit destroy_admin_user_session_path
    expect(page).to have_content 'Войти'
  end
end
