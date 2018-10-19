RSpec.describe PgObjects::Config do
  describe 'gem configuration' do
    let(:subject) { PgObjects.config }

    it 'has default directories value' do
      expect(subject.directories).to eq(['db/objects'])
    end

    it 'has default extensions value' do
      expect(subject.extensions).to eq(['sql'])
    end

    it 'has default silent value' do
      expect(subject.silent).to be_falsy
    end
  end
end
