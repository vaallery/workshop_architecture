module LoginHelpers
  def login(user)
    visit new_admin_user_session_path
    within('#new_admin_user') do
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
    end
    click_button 'Войти'
  end
end
