RSpec.describe Books::LinksService do
  subject(:operation) { described_class }

  let(:books) { File.readlines('spec/fixtures/fb2-ru-ok-sf.inp') }
  let(:genres_map) { Genre.pluck(:slug, :id).to_h }
  let(:keywords_map) { Keyword.pluck(:name, :id).to_h }
  let(:authors_map) { Author.pluck(:original, :id).to_h }

  before { inp_load_without_links('spec/fixtures/fb2-ru-ok-sf.inp') }

  context 'когда переданы корректные параметры' do
    let(:params) do
      {
        books: books,
        genres_map: genres_map,
        keywords_map: keywords_map,
        authors_map: authors_map
      }
    end

    it 'связи книг с жанрами успешно добавляются в базу данных' do
      expect { operation.call(**params) }.to change(BooksGenre, :count).by(10)
    end

    it 'связи книг с ключевыми словами успешно добавляются в базу данных' do
      expect { operation.call(**params) }.to change(BooksKeyword, :count).by(12)
    end

    it 'связи книг с авторами успешно добавляются в базу данных' do
      expect { operation.call(**params) }.to change(BooksAuthor, :count).by(10)
    end
  end

  context 'когда' do
    let(:without_collection) do
      {
        books: nil,
        genres_map: genres_map,
        keywords_map: keywords_map,
        authors_map: authors_map
      }
    end

    it 'не указаны параметры для ключей' do
      expect {
        operation.call(
          books,
          genres_map,
          keywords_map,
          authors_map) }.to raise_error(KeyError)
    end

    it 'передан несуществующий файл' do
      expect { operation.call(**without_collection) }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end
