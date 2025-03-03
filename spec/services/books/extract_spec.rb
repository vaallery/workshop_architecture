RSpec.describe Books::ExtractService do
  subject(:operation) { described_class }
  let(:book) { create(:extract_book) }

  context 'когда переданы корректные параметры' do
    let(:params) { { id: book.id } }
    let(:extract_folder) { Settings.app.extract_folder }

    it 'возвращается хэш с результатами' do
      expect(operation.call(**params)).to a_kind_of(Hash)
    end

    it 'файл успешно извелекается' do
      expect(Pathname.new(operation.call(**params).dig(:tempfile))).to exist
    end

    it 'архив существует' do
      RSpec::Expectations.configuration.on_potential_false_positives = :nothing
      expect { operation.call(**params) }.not_to raise_error(Zip::Error)
    end
  end
end
