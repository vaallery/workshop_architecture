RSpec.describe Genre, type: :model do
  context 'в невалидном состоянии' do
    let(:genre_group) { build(:invalid_genre_group) }

    it 'когда имя не заполнено' do
      expect(genre_group.validate).to be_falsey
      error_message = 'Название обязательно для заполнения'
      expect(genre_group.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:genre_group) { create(:genre_group) }

    it { is_expected.to have_many(:genres).dependent(:destroy) }
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
