module PgObjects
  ##
  # Brings rake tasks to rails app
  class Railtie < Rails::Railtie
    # initializer 'pg_objects.initialization' do |app|
    # end

    rake_tasks do
      load 'tasks/pg_objects_tasks.rake'
    end
  end
end
