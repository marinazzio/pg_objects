RSpec.describe PgObjects::Config do
  after { described_class.reset_config }

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

  describe 'custom configuration from block' do
    before do
      @old_config = PgObjects.config

      PgObjects.configure do |config|
        config.before_path = 'block_config/db/objects/before'
        config.after_path = 'block_config/db/objects/after'
        config.extensions = %w[sql erb block_config]
        config.silent = true
      end
    end

    it 'loads before path' do
      expect(PgObjects.config.before_path).to eq('block_config/db/objects/before')
    end

    it 'loads after path' do
      expect(PgObjects.config.after_path).to eq('block_config/db/objects/after')
    end

    it 'loads extensions' do
      expect(PgObjects.config.extensions).to match_array(%w[block_config sql erb])
    end

    it 'loads silent' do
      expect(PgObjects.config.silent).to be_truthy
    end
  end

  describe 'custom configuration from YAML' do
    let(:config_path) { 'spec/fixtures/pg_objects.yml' }

    before do
      described_class.load_from_yaml(config_path)
    end

    it 'loads before path' do
      expect(PgObjects.config.before_path).to eq('yaml/objects/before')
    end

    it 'loads after path' do
      expect(PgObjects.config.after_path).to eq('yaml/objects/after')
    end

    it 'loads extensions' do
      expect(PgObjects.config.extensions).to match_array(%w[yaml sql txt])
    end

    it 'loads silent' do
      expect(PgObjects.config.silent).to be_truthy
    end
  end
end
