RSpec.describe Keyword, type: :model do
  it_behaves_like 'ransack'

  context 'в невалидном состоянии' do
    let(:keyword) { build(:invalid_keyword) }

    it 'когда название не заполнено' do
      expect(keyword.validate).to be_falsey
      error_message = 'Название обязательно для заполнения'
      expect(keyword.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:keyword) { create(:keyword) }

    it { is_expected.to have_many(:books_keywords).dependent(:destroy) }
    it { is_expected.to have_many(:books) }
    it { is_expected.to accept_nested_attributes_for(:books) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
