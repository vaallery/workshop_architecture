RSpec.describe Books::ParseService do
  subject(:operation) { described_class }

  let(:books) { File.readlines('spec/fixtures/fb2-ru-ok-sf.inp') }

  before(:all) do
    inp_load_genres_langualges_folders('spec/fixtures/fb2-ru-ok-sf.inp')
  end

  context 'когда переданы корректные параметры' do
    let(:params) { { books: books } }

    it 'книги успешно добавляются в базу данных' do
      expect { operation.call(**params) }.to change(Book, :count).by(10)
    end
  end

  context 'когда' do
    it 'не указаны параметры для ключей' do
      expect { operation.call(books, 2) }.to raise_error(KeyError)
    end

    it 'передан несуществующий файл' do
      expect { operation.call(books: nil) }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end
