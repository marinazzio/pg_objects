module PgObjects
  ##
  # Console output
  #
  # Passs +true+ to constructor to suppress output
  class Logger
    attr_reader :silent

    def initialize(silent = false)
      @silent = silent
    end

    def write(str)
      puts "== #{str} ".ljust(80, '=') unless silent
    end
  end
end
