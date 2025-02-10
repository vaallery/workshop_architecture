RSpec.describe Folder, type: :model do
  context 'в невалидном состоянии' do
    let(:folder) { build(:invalid_folder) }

    it 'когда название не заполнено' do
      expect(folder.validate).to be_falsey
      error_message = 'Название папки обязательно для заполнения'
      expect(folder.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:folder) { create(:folder) }

    it { is_expected.to have_many(:books).dependent(:destroy) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
