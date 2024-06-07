RSpec.shared_examples 'parsed object' do
  it 'has a proper object name' do
    expect(subject.name).to eq(object_name)
  end
end
