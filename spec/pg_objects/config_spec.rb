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

  describe 'custom configuration from YAML with silent: false' do
    let(:config_path) { 'spec/fixtures/pg_objects_silent_false.yml' }

    before do
      PgObjects.configure { |config| config.silent = true }
      described_class.load_from_yaml(config_path)
    end

    it 'applies silent: false, overriding a previously truthy value' do
      expect(PgObjects.config.silent).to be(false)
    end
  end

  describe 'custom configuration from YAML with blank values' do
    let(:config_path) { 'spec/fixtures/pg_objects_blank_values.yml' }

    before do
      PgObjects.configure do |config|
        config.before_path = 'preset/before'
        config.extensions = ['sql']
        config.silent = true
      end
      described_class.load_from_yaml(config_path)
    end

    it 'ignores blank string and empty array values', :aggregate_failures do
      expect(PgObjects.config.before_path).to eq('preset/before')
      expect(PgObjects.config.extensions).to eq(['sql'])
    end

    it 'still applies boolean false' do
      expect(PgObjects.config.silent).to be(false)
    end
  end

  describe 'partial YAML config' do
    before { described_class.load_from_yaml(config_path) }

    context 'with only directories set' do
      let(:config_path) { 'spec/fixtures/pg_objects_directories_only.yml' }

      it 'applies directories and preserves other defaults', :aggregate_failures do
        expect(PgObjects.config.before_path).to eq('yaml/only/before')
        expect(PgObjects.config.after_path).to eq('yaml/only/after')
        expect(PgObjects.config.extensions).to eq(['sql'])
        expect(PgObjects.config.silent).to be(false)
      end
    end

    context 'with only extensions set' do
      let(:config_path) { 'spec/fixtures/pg_objects_extensions_only.yml' }

      it 'applies extensions and preserves path defaults', :aggregate_failures do
        expect(PgObjects.config.extensions).to match_array(%w[erb txt])
        expect(PgObjects.config.before_path).to eq('db/objects/before')
        expect(PgObjects.config.after_path).to eq('db/objects/after')
      end
    end

    context 'with only silent set' do
      let(:config_path) { 'spec/fixtures/pg_objects_silent_only.yml' }

      it 'applies silent and preserves path/extension defaults', :aggregate_failures do
        expect(PgObjects.config.silent).to be(true)
        expect(PgObjects.config.before_path).to eq('db/objects/before')
        expect(PgObjects.config.extensions).to eq(['sql'])
      end
    end
  end

  describe 'partial YAML config over a customized config' do
    let(:config_path) { 'spec/fixtures/pg_objects_extensions_only.yml' }

    before do
      PgObjects.configure do |config|
        config.before_path = 'preset/before'
        config.silent = true
      end
      described_class.load_from_yaml(config_path)
    end

    it 'applies present keys and leaves omitted keys at their previously set values', :aggregate_failures do
      expect(PgObjects.config.extensions).to match_array(%w[erb txt])
      expect(PgObjects.config.before_path).to eq('preset/before')
      expect(PgObjects.config.silent).to be(true)
    end
  end
end
