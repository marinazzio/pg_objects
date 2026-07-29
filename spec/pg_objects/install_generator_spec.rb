# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'rails/generators'
require 'generators/pg_objects/install/install_generator'

RSpec.describe PgObjects::InstallGenerator do
  let(:destination_root) { Dir.mktmpdir }

  before do
    described_class.start(['--quiet'], destination_root: destination_root)
  end

  after { FileUtils.remove_entry(destination_root) }

  it 'creates the db/objects directory' do
    expect(File).to be_directory(File.join(destination_root, 'db/objects'))
  end

  it 'creates the db/objects/before directory' do
    expect(File).to be_directory(File.join(destination_root, 'db/objects/before'))
  end

  it 'creates the db/objects/after directory' do
    expect(File).to be_directory(File.join(destination_root, 'db/objects/after'))
  end

  it 'creates nothing outside the destination root', :aggregate_failures do
    entries = Dir.children(destination_root)

    expect(entries).to eq(['db'])
    expect(Dir.children(File.join(destination_root, 'db'))).to eq(['objects'])
  end
end
