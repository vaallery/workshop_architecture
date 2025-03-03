RSpec.describe Languages::CounterCacheCommand do
  subject(:operation) { described_class }

  before { inp_full_load('spec/fixtures/fb2-ru-ok-sf.inp') }

  it 'успешно пересчитывается counter-cache поле' do
    expect { operation.call }.to change { Language.find_by(slug: 'ru').books_count }.by(10)
  end
end
