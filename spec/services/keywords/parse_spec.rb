RSpec.describe Keywords::ParseService do
  subject(:operation) { described_class }

  let(:books) { File.readlines('spec/fixtures/fb2-ru-ok-sf.inp') }

  context 'когда переданы корректные параметры' do
    let(:with_limit) { { books: books, limit: 2 } }
    let(:without_limit) { { books: books } }

    it 'ограничение limit срабатывает корректно' do
      expect(operation.call(**with_limit).count).to eq(2)
    end

    it 'возвращаемая структура данных корректна' do
      expect(operation.call(**with_limit)).to include('sf')
    end

    it 'без ограничения, возвращается все содержимое файла' do
      expect(operation.call(**without_limit).count).to eq(12)
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
