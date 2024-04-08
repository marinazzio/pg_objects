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

    setting :before_path, default: 'db/objects/before'
    setting :after_path, default: 'db/objects/after'
    setting :extensions, default: ['sql']
    setting :silent, default: false
  end
end
