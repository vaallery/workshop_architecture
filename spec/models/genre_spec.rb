RSpec.describe Genre, type: :model do
  context 'в невалидном состоянии' do
    let(:genre) { build(:invalid_genre) }

    it 'когда имя не заполнено' do
      expect(genre.validate).to be_falsey
      error_message = 'Обозначение обязательно для заполнения'
      expect(genre.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:genre) { create(:genre) }

    it { is_expected.to have_many(:books_genres).dependent(:destroy) }
    it { is_expected.to have_many(:books) }
    it { is_expected.to accept_nested_attributes_for(:books) }

    it { is_expected.to belong_to(:genre_group) }
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end
end
