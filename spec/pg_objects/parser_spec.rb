RSpec.describe PgObjects::Parser do
  include SourceHelpers

  using RSpec::Parameterized::TableSyntax

  subject { described_class.new.load(source) }

  context 'with depends_on directives' do
    let(:source) { trigger_source }
    let(:fetched_deps) { ['here/is/a/path/to/object.sql', 'some/path/to/another.sql'] }

    it 'fetches depends_on directives' do
      dirs = subject.fetch_directives
      expect(dirs[:depends_on].sort).to eq(fetched_deps.sort)
    end
  end

  context 'with no create query' do
    let(:source) { no_create_source }

    it 'fetches nil as object_name when it is impossible' do
      expect(subject.fetch_object_name).to be_nil
    end
  end

  describe 'depends_on edge cases' do
    subject(:deps) { described_class.new.load(source).fetch_directives[:depends_on] }

    context 'with a --! prefixed directive' do
      let(:source) { "--!depends_on foo\nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with a #! prefixed directive' do
      let(:source) { "#!depends_on foo\nSELECT 1;" }

      it 'parses the #! prefix' do
        expect(deps).to eq(['foo'])
      end
    end

    context 'with extra spaces around the dependency name' do
      let(:source) { "--!depends_on     foo\nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with a tab between the directive and the dependency' do
      let(:source) { "--!depends_on\tfoo\nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with trailing whitespace after the dependency' do
      let(:source) { "--!depends_on foo   \nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with a leading-indented directive' do
      let(:source) { "   --!depends_on foo\nSELECT 1;" }

      it 'is not parsed because the prefix must start the line' do
        expect(deps).to eq([])
      end
    end

    context 'with a directive in the middle of the file' do
      let(:source) { "SELECT 1;\n--!depends_on foo\nSELECT 2;" }

      it 'parses directives located anywhere in the file' do
        expect(deps).to eq(['foo'])
      end
    end

    context 'with a header-only directive' do
      let(:source) { "--!depends_on foo\nSELECT 1;\nSELECT 2;" }

      it { should eq(['foo']) }
    end

    context 'with no directives' do
      let(:source) { "SELECT 1;\nSELECT 2;" }

      it 'returns an empty array' do
        expect(deps).to eq([])
      end
    end

    context 'with multiple distinct dependencies' do
      let(:source) { "--!depends_on foo\n--!depends_on bar\nSELECT 1;" }

      it { should eq(%w[foo bar]) }
    end

    context 'with duplicate dependencies' do
      let(:source) { "--!depends_on foo\n--!depends_on foo\nSELECT 1;" }

      it 'preserves duplicates' do
        expect(deps).to eq(%w[foo foo])
      end
    end

    context 'with an unknown directive' do
      let(:source) { "--!something_else whatever\nSELECT 1;" }

      it 'is ignored' do
        expect(deps).to eq([])
      end
    end

    context 'with a depends_on directive that has no dependency name' do
      let(:source) { "--!depends_on\nSELECT 1;" }

      it 'is ignored' do
        expect(deps).to eq([])
      end
    end
  end
end
