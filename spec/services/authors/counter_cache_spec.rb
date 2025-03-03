RSpec.describe Authors::CounterCacheCommand do
  subject(:operation) { described_class }

  let(:fio) { 'Алешкин,Тимофей,Владимирович' }

  before { inp_full_load('spec/fixtures/fb2-ru-ok-sf.inp') }

  it 'успешно пересчитывается counter-cache поле' do
    expect { operation.call }.to change { Author.find_by(original: fio).books_count }.by(7)
  end
end
