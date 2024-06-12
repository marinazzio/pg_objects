##
# Creates default directories structure
class PgObjects::InstallGenerator < Rails::Generators::Base
  desc 'Creates directories structure in `db` directory of the Rails application and initializes configuration files'
  def create_directories
    empty_directory 'db/objects'
    empty_directory 'db/objects/before'
    empty_directory 'db/objects/after'
  end
end
