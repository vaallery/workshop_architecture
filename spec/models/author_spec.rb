RSpec.describe Author, type: :model do
  it_behaves_like 'ransack'

  context 'в невалидном состоянии' do
    let(:author) { build(:invalid_author) }

    it 'когда имя не заполнено' do
      expect(author.validate).to be_falsey
      error_message = 'Имя обязательно для заполнения'
      expect(author.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:author) { create(:author) }

    it { is_expected.to have_many(:books_authors) }
    it { is_expected.to have_many(:books) }
    it { is_expected.to accept_nested_attributes_for(:books) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:first_name) }
    it do
      fields = %i[last_name middle_name original]
      is_expected.to validate_uniqueness_of(:first_name).scoped_to(*fields)
    end
  end
end
