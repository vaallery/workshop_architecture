RSpec.describe Genres::CounterCacheCommand do
  subject(:operation) { described_class }

  before { inp_full_load('spec/fixtures/fb2-ru-ok-sf.inp') }

  it 'успешно пересчитывается counter-cache поле' do
    expect { operation.call }.to change { Genre.find_by(slug: 'sf_history').books_count }.by(7)
  end
end
