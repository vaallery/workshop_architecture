RSpec.describe AdminUser, type: :model do
  context 'в невалидном состоянии' do
    let(:admin_user) { build(:invalid_admin_user) }

    it 'когда имя не заполнено' do
      expect(admin_user.validate).to be_falsey

      error_message = 'Email обязательно для заполнения'
      expect(admin_user.errors.full_messages).to include error_message

      error_message = 'Пароль обязательно для заполнения'
      expect(admin_user.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:admin_user) { create(:admin_user) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:email) }
  end
end
