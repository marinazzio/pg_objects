RSpec.describe PgObjects::Config do
  describe 'gem configuration' do
    subject { PgObjects.config }

    it 'has default before path' do
      expect(subject.before_path).to eq('db/objects/before')
    end

    it 'has default after path' do
      expect(subject.after_path).to eq('db/objects/after')
    end

    it 'has default extensions value' do
      expect(subject.extensions).to eq(['sql'])
    end

    it 'has default silent value' do
      expect(subject.silent).to be_falsy
    end
  end
end
