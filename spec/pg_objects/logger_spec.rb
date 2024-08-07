RSpec.describe PgObjects::Logger do
  let(:test_string) { 'test string' }

  context 'with default silent option' do
    before do
      allow(subject.config).to receive(:silent).and_return(false)
    end

    it 'writes to console' do
      expect { subject.write(test_string) }.to output.to_stdout
    end
  end

  context 'with activated silent mode' do
    before do
      allow(subject.config).to receive(:silent).and_return(true)
    end

    it 'does not write to console when silent is true' do
      expect { subject.write(test_string) }.not_to output.to_stdout
    end
  end
end
