RSpec.describe Seeds::SqlDumpLoad do
  subject(:operation) { described_class }

  let(:not_exist_filename) { 'spec/development.sql' }
  let(:filename) { 'spec/fixtures/development.sql' }

  before :each do
    allow_any_instance_of(described_class).to receive(:drop_tables).and_return(true)
    allow_any_instance_of(described_class).to receive(:load_sql_dump).and_return(true)
  end

  context 'когда переданы корректные параметры' do
    it 'cервис-объект успешно выполняется' do
      expect(operation.call(filename: filename)).to be_truthy
    end

    it 'обрабатывается корректный список таблиц' do
      expect(Seeds::SqlDumpLoad::LIST_OF_TABLES.count).to be 13
    end
  end

  context 'когда передан несуществующий файл' do
    it 'cервис-объект выполняется не успешно' do
      expect(operation.call(filename: not_exist_filename)).to be_falsy
    end
  end
end
