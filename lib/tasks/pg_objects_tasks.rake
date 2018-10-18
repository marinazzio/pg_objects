namespace :db do
  desc 'Generate all the database objects of the current project'
  task create_objects: :environment do
    PgObjects::Manager.new.load_files.create_objects
  end
end

require 'rake/hooks'

after 'db:migrate' do
  Rake::Task['db:create_objects'].invoke
end

after 'db:rollback' do
  Rake::Task['db:create_objects'].invoke
end
