RSpec.describe Authors::ParseService do
  subject(:operation) { described_class }

  let(:books) { File.readlines('spec/fixtures/fb2-ru-ok-sf.inp') }
  let(:incomplete_authors) { File.readlines('spec/fixtures/fb2-incomplete-authors.inp') }

  context 'когда переданы корректные параметры' do
    let(:with_limit) { { books: books, limit: 2 } }
    let(:without_limit) { { books: books } }
    let(:stuct_of_author) {
      include(
        first_name: be_an(String),
        last_name: be_an(String),
        middle_name: be_an(String) | be_nil,
        original: be_an(String)
      )
    }

    it 'ограничение limit срабатывает корректно' do
      expect(operation.call(**with_limit).count).to eq(2)
    end

    it 'возвращаемая структура данных корректна' do
      expect(operation.call(**with_limit)).to include(stuct_of_author)
    end

    it 'без ограничения, возвращается все содержимое файла' do
      expect(operation.call(**without_limit).count).to eq(10)
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

  context 'когда авторы не полные' do
    let(:result) { operation.call(books: incomplete_authors) }
    let(:authors) do
      incomplete_authors.each_with_object([]) do |line, res|
        elems = line.split(4.chr).first.chomp(':').split(':')
        res << elems.first
      end
    end

    it 'поле с оригиналом заполняется корректно' do
      expect(result.first.first.dig(:original)).to eq(authors.first)
    end

    it 'поле с оригиналом заполняется корректно' do
      expect(result.last.first.dig(:original)).to eq(authors.last)
    end
  end
end
