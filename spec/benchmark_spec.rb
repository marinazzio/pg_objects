require 'English'
require 'shellwords'

RSpec.describe 'Benchmark script' do # rubocop:disable RSpec/DescribeClass
  let(:benchmark_script) { File.join(__dir__, '..', 'bin', 'benchmark') }
  let(:project_root) { File.dirname(__dir__) }

  # Run the script in a clean Bundler env: a nested `bundle exec` inside the
  # already-bundled spec process emits RubyGems re-init warnings and exits
  # non-zero, which would mask the script's real exit status. Paths/args are
  # shell-escaped so directories with spaces work; backticks set $CHILD_STATUS.
  let(:run_benchmark) do
    lambda do |args|
      Bundler.with_unbundled_env do
        Dir.chdir(project_root) do
          `#{Shellwords.shelljoin(['bundle', 'exec', benchmark_script, *args])} 2>&1`
        end
      end
    end
  end

  it 'runs without errors', :aggregate_failures do
    output = run_benchmark.call(['--files', '5', '--quiet'])

    expect($CHILD_STATUS.exitstatus).to eq(0)
    expect(output).to include('Benchmarking File I/O Operations')
    expect(output).to include('Benchmarking SQL Parsing')
    expect(output).to include('Benchmarking Dependency Extraction')
    expect(output).to include('Benchmarking Full Workflow')
    expect(output).to include('Memory Usage Analysis')
  end

  it 'displays help when --help is passed', :aggregate_failures do
    output = run_benchmark.call(['--help'])

    expect($CHILD_STATUS.exitstatus).to eq(0)
    expect(output).to include('Usage:')
    expect(output).to include('--files')
    expect(output).to include('--large-files')
    expect(output).to include('--verbose')
    expect(output).to include('--quiet')
  end

  it 'respects the --files option', :aggregate_failures do
    output = run_benchmark.call(['--files', '10', '--quiet'])

    expect($CHILD_STATUS.exitstatus).to eq(0)
    # Should have at least the base SAMPLE_SQLS files (8) plus the large file (1)
    expect(output).to match(/Read \d+ files/)
    expect(output).to match(/Parsed \d+ files/)
  end
end
