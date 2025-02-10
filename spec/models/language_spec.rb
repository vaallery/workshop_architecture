RSpec.describe Language, type: :model do
  it_behaves_like 'ransack'

  context 'в невалидном состоянии' do
    let(:language) { build(:invalid_language) }

    it 'когда код не заполнен' do
      expect(language.validate).to be_falsey
      error_message = 'Код языка обязательно для заполнения'
      expect(language.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:language) { create(:language) }

    it { is_expected.to have_many(:books) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end
end
