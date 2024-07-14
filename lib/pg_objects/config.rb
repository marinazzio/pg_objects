require_relative 'yaml_configurable'

module PgObjects
  ##
  # Use to set custom configuration:
  #
  #   PgObjects.configure do |config|
  #     # use relative from RAILS_ROOT
  #     config.before_path = 'db/alternate/before'
  #     # or full
  #     config.after_path = '/var/tmp/alternate/after'
  #     config.extensions = ['sql', 'txt']
  #     # suppress output to console
  #     config.silent = true
  #   end
  class << self
    def configure
      yield Config.config
    end

    def config
      Config.config
    end
  end

  class Config
    extend Dry::Configurable
    extend YamlConfigurable

    setting :before_path, default: 'db/objects/before'
    setting :after_path, default: 'db/objects/after'
    setting :extensions, default: ['sql']
    setting :silent, default: false

    load_from_yaml 'config/pg_objects.yml'
  end
end
