RSpec.describe PgObjects::Config do
  describe 'gem configuration' do
    let(:subject) { PgObjects.config }

    it 'has default directories value' do
      expect(subject.directories).to eq(['db/objects'])
    end

    it 'has default extensions value' do
      expect(subject.extensions).to eq(['sql'])
    end
  end
end
