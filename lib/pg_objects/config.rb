module PgObjects
  ##
  # Use to set custom configuration:
  #
  #   PgObjects.configure do |config|
  #     # use relative from RAILS_ROOT
  #     config.before_path = 'db/alternate/before'
  #     # or full (not recommended)
  #     config.after_path = '/var/tmp/alternate/after'
  #     config.extensions = ['sql', 'txt']
  #     # suppress output to console
  #     config.silent = true
  #   end
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end
  end

  class Config
    attr_accessor :before_path, :after_path, :extensions, :silent

    def initialize
      @before_path = 'db/objects/before'
      @after_path = 'db/objects/after'
      @extensions = ['sql']
      @silent = false
    end
  end
end
