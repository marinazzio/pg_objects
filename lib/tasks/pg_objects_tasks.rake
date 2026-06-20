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

# Attach object-creation hooks to the tasks configured in
# PgObjects::Config.config.hook_tasks (override in an initializer to opt out).
# Each stage (:before/:after) maps to both the rake-hooks DSL method and the
# matching db:create_objects:<stage> task.
PgObjects::Config.config.hook_tasks.each do |task_name, stages|
  stages.each do |stage|
    send(stage, task_name) do
      task = Rake::Task["db:create_objects:#{stage}"]
      task.reenable # allow the hook to run again within composed/repeated task runs
      task.invoke
    end
  end
end
