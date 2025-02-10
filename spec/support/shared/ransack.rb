RSpec.shared_context 'ransack' do
  it 'метод ransackable_attributes' do
    expect(described_class.ransackable_attributes).to eq(described_class::PUBLIC_FIELDS)
  end

  it 'метод ransackable_associations' do
    expect(described_class.ransackable_associations).to eq(described_class::RANSACK_ASSOCIATIONS)
  end
end
