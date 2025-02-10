RSpec.describe BooksGenre do
  let(:books_keyword) { create(:books_keyword) }

  subject { books_keyword }

  describe 'has valid associations' do
    it { is_expected.to belong_to(:book) }
    it { is_expected.to belong_to(:keyword) }

    it { is_expected.to be_valid }
  end
end
