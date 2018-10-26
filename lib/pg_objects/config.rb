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
    attr_accessor :before_path, :after_path, :extensions, :silent

    def initialize
      @before_path = 'db/objects/before'
      @after_path = 'db/objects/after'
      @extensions = ['sql']
      @silent = false
    end
  end
end
