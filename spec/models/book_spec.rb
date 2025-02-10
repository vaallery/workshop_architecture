RSpec.describe Book, type: :model do
  it_behaves_like 'ransack'

  context 'в невалидном состоянии' do
    let(:book) { build(:invalid_book) }

    it 'когда название не заполнено' do
      expect(book.validate).to be_falsey
      error_message = 'Название обязательно для заполнения'
      expect(book.errors.full_messages).to include error_message
    end

    it 'когда идентификатор файла не заполнен' do
      expect(book.validate).to be_falsey
      error_message = 'Идентификатор файла в библиотеке обязательно для заполнения'
      expect(book.errors.full_messages).to include error_message
    end

    it 'когда размер не заполнен' do
      expect(book.validate).to be_falsey
      error_message = 'Размер файла обязательно для заполнения'
      expect(book.errors.full_messages).to include error_message
    end

    it 'когда название файла не заполнено' do
      expect(book.validate).to be_falsey
      error_message = 'Название файла обязательно для заполнения'
      expect(book.errors.full_messages).to include error_message
    end
  end

  context 'в валидном состоянии' do
    subject(:book) { create(:book) }

    it { is_expected.to have_many(:books_authors).dependent(:destroy) }
    it { is_expected.to have_many(:authors) }
    it { is_expected.to accept_nested_attributes_for(:authors) }

    it { is_expected.to have_many(:books_genres).dependent(:destroy) }
    it { is_expected.to have_many(:genres) }
    it { is_expected.to accept_nested_attributes_for(:genres) }

    it { is_expected.to have_many(:books_keywords).dependent(:destroy) }
    it { is_expected.to have_many(:keywords) }
    it { is_expected.to accept_nested_attributes_for(:keywords) }

    it { is_expected.to belong_to(:folder) }
    it { is_expected.to belong_to(:language) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:libid) }
    it { is_expected.to validate_presence_of(:size) }
    it { is_expected.to validate_presence_of(:filename) }
  end
end
