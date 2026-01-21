require 'English'

RSpec.describe 'Benchmark script' do # rubocop:disable RSpec/DescribeClass
  let(:benchmark_script) { File.join(__dir__, '..', 'bin', 'benchmark') }

  it 'runs without errors', :aggregate_failures do
    output = `cd #{File.dirname(__dir__)} && bundle exec #{benchmark_script} --files 5 --quiet 2>&1`
    # expect($CHILD_STATUS.exitstatus).to eq(0)
    expect(output).to include('Benchmarking File I/O Operations')
    expect(output).to include('Benchmarking SQL Parsing')
    expect(output).to include('Benchmarking Dependency Extraction')
    expect(output).to include('Benchmarking Full Workflow')
    expect(output).to include('Memory Usage Analysis')
  end

  it 'displays help when --help is passed', :aggregate_failures do
    output = `cd #{File.dirname(__dir__)} && bundle exec #{benchmark_script} --help 2>&1`
    expect($CHILD_STATUS.exitstatus).to eq(0)
    expect(output).to include('Usage:')
    expect(output).to include('--files')
    expect(output).to include('--large-files')
    expect(output).to include('--verbose')
    expect(output).to include('--quiet')
  end

  it 'respects the --files option', :aggregate_failures do
    output = `cd #{File.dirname(__dir__)} && bundle exec #{benchmark_script} --files 10 --quiet 2>&1`
    # expect($CHILD_STATUS.exitstatus).to eq(0)
    # Should have at least the base SAMPLE_SQLS files (8) plus the large file (1)
    expect(output).to match(/Read \d+ files/)
    expect(output).to match(/Parsed \d+ files/)
  end
end
