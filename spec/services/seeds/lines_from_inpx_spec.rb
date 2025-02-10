RSpec.describe Seeds::LinesFromInpx do
  subject(:operation) { described_class }

  let(:files) { [ *1..10 ].map { |i| format('spec/fixtures/inpx/fb2-ru-ok-sf-%02d.inp', i) } }
  let(:wrong_files) { [ *1..10 ].map { |i| format('spec/not-existing-%02d.inp', i) } }

  context 'когда переданы корректные параметры' do
    it 'возвращается массив строк' do
      expect(operation.call(files: files).count).to eq(20)
    end
  end

  context 'когда' do
    it 'передан несуществующий файл' do
      expect { operation.call(files: wrong_files) }.to raise_error(Errno::ENOENT)
    end
  end
end
