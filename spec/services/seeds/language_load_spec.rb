RSpec.describe Seeds::LanguageLoad do
  subject(:operation) { described_class }

  let(:filename) { 'spec/fixtures/languages.yml' }
  let(:not_existing_filename) { 'spec/fixtures/not_exist.yml' }

  before(:all) { Language.destroy_all }

  context 'когда переданы корректные параметры' do
    let(:params) { { filename: filename } }

    it 'сервис объект развертывает языки' do
      expect { operation.call(**params) }.to change(Language, :count).by(5)
    end
  end

  context 'когда' do
    let(:with_not_existing_file) { { filename: not_existing_filename } }

    it 'передан несуществующий файл' do
      expect { operation.call(**with_not_existing_file) }.to raise_error(Errno::ENOENT)
    end
  end
end
