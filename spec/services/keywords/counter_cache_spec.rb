RSpec.describe Keywords::CounterCacheCommand do
  subject(:operation) { described_class }

  before { inp_full_load('spec/fixtures/fb2-ru-ok-sf.inp') }

  it 'успешно пересчитывается counter-cache поле' do
    expect { operation.call }.to change { Keyword.find_by(name: 'sf').books_count }.by(9)
  end
end
