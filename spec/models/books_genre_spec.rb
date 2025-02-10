RSpec.describe BooksGenre do
  let(:books_genre) { create(:books_genre) }

  subject { books_genre }

  describe 'has valid associations' do
    it { is_expected.to belong_to(:book) }
    it { is_expected.to belong_to(:genre) }

    it { is_expected.to be_valid }
  end
end
