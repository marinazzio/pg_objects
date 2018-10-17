namespace :db do
  desc 'Generate all the database objects of the current project'
  task create_objects: :environment do
    PgObjects::Manager.new.load_files.create_objects
  end

  desc 'Drop all the database objects of the current project'
  task drop_objects: :environment do
    PgObjects::Manager.new.load_files.drop_objects
  end
end

require 'rake/hooks'

before 'db:migrate' do
  Rake::Task['db:drop_objects'].invoke
end

before 'db:rollback' do
  Rake::Task['db:drop_objects'].invoke
end

after 'db:migrate' do
  Rake::Task['db:create_objects'].invoke
end

after 'db:rollback' do
  Rake::Task['db:create_objects'].invoke
end
