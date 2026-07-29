require 'stringio'

RSpec.describe PgObjects::Logger do
  subject(:logger) { described_class.new(stream: io) }

  let(:io) { StringIO.new }
  let(:test_string) { 'test string' }
  let(:silent) { false }

  before do
    allow(logger.config).to receive(:silent).and_return(silent)
  end

  it 'writes to the injected stream, padded to 80 characters' do
    logger.write(test_string)

    expect(io.string).to eq("#{"== #{test_string} ".ljust(80, '=')}\n")
  end

  it 'writes to $stdout by default' do
    allow(PgObjects::Config.config).to receive(:silent).and_return(false)

    expect { described_class.new.write(test_string) }.to output(/#{test_string}/).to_stdout
  end

  it 'logs info without a level tag' do
    logger.info(test_string)

    expect(io.string).to start_with("== #{test_string} ")
  end

  it 'tags warn messages' do
    logger.warn(test_string)

    expect(io.string).to start_with("== [WARN] #{test_string} ")
  end

  it 'tags error messages' do
    logger.error(test_string)

    expect(io.string).to start_with("== [ERROR] #{test_string} ")
  end

  context 'with activated silent mode' do
    let(:silent) { true }

    it 'suppresses write' do
      logger.write(test_string)

      expect(io.string).to be_empty
    end

    it 'suppresses info' do
      logger.info(test_string)

      expect(io.string).to be_empty
    end

    it 'suppresses warn' do
      logger.warn(test_string)

      expect(io.string).to be_empty
    end

    it 'still writes error' do
      logger.error(test_string)

      expect(io.string).to start_with("== [ERROR] #{test_string} ")
    end
  end
end
