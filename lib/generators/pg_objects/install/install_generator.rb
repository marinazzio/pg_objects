##
# Creates default directories structure
class PgObjects::InstallGenerator < Rails::Generators::Base
  def create_directories
    empty_directory 'db/objects'
    empty_directory 'db/objects/before'
    empty_directory 'db/objects/after'
  end
end
