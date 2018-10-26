namespace :db do
  namespace :create_objects do
    desc 'Create all the database objects from "before" folder'
    task before: :environment do
      PgObjects::Manager.new.load_files(:before).create_objects
    end

    desc 'Create all the database objects from "after" folder'
    task after: :environment do
      PgObjects::Manager.new.load_files(:after).create_objects
    end
  end
end

require 'rake/hooks'

before 'db:migrate' do
  Rake::Task['db:create_objects:before'].invoke
end

after 'db:migrate' do
  Rake::Task['db:create_objects:after'].invoke
end
