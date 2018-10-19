RSpec.describe PgObjects::Logger do
  let(:test_string) { 'test string' }

  it 'writes to console when silent is false (by default)' do
    expect { subject.write(test_string) }.to output.to_stdout
  end

  it 'does not write to console when silent is true' do
    subject = described_class.new(true)

    expect { subject.write(test_string) }.not_to output.to_stdout
  end
end
