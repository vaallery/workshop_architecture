RSpec.describe BooksAuthor do
  let(:books_author) { create(:books_author) }

  subject { books_author }

  describe 'has valid associations' do
    it { is_expected.to belong_to(:book) }
    it { is_expected.to belong_to(:author) }

    it { is_expected.to be_valid }
  end
end
