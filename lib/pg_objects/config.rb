module PgObjects
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end
  end

  class Config
    attr_accessor :directories, :extensions

    def initialize
      @directories = ['db/objects']
      @extensions = ['sql']
    end
  end
end
