RSpec.describe Languages::ParseService do
  subject(:operation) { described_class }

  let(:filename) { 'spec/fixtures/fb2-ru-ok-sf.inp' }
  let(:not_existing_filename) { 'spec/fixtures/not_exist.inp' }

  context 'когда переданы корректные параметры' do
    let(:with_limit) { { filename: filename, limit: 2 } }
    let(:without_limit) { { filename: filename } }

    it 'ограничение limit срабатывает корректно' do
      expect(operation.call(**with_limit).count).to eq(2)
    end

    it 'возвращаемая структура данных корректна' do
      expect(operation.call(**with_limit)).to include('ru')
    end

    it 'без ограничения, возвращается все содержимое файла' do
      expect(operation.call(**without_limit).count).to eq(10)
    end
  end

  context 'когда' do
    let(:with_not_existing_file) { { filename: not_existing_filename } }

    it 'не указаны параметры для ключей' do
      expect { operation.call(filename, 2) }.to raise_error(KeyError)
    end

    it 'передан несуществующий файл' do
      expect { operation.call(**with_not_existing_file) }.to raise_error(Errno::ENOENT)
    end
  end
end
