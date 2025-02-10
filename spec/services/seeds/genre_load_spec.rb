RSpec.describe Seeds::GenreLoad do
  subject(:operation) { described_class }

  let(:filename) { 'spec/fixtures/generes.yml' }
  let(:not_existing_filename) { 'spec/fixtures/not_exist.yml' }

  before(:all) { GenreGroup.destroy_all }

  context 'когда переданы корректные параметры' do
    let(:params) { { filename: filename } }

    it 'сервис объект развертывает жанры' do
      expect { operation.call(**params) }.to change(Genre, :count).by(5)
    end

    it 'сервис объект развертывает группы жанров' do
      expect { operation.call(**params) }.to change(GenreGroup, :count).by(1)
    end
  end

  context 'когда' do
    let(:with_not_existing_file) { { filename: not_existing_filename } }

    it 'передан несуществующий файл' do
      expect { operation.call(**with_not_existing_file) }.to raise_error(Errno::ENOENT)
    end
  end
end
