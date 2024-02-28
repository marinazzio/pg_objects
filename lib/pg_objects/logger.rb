##
# Console output
#
class PgObjects::Logger
  attr_reader :silent

  def initialize
    @silent = false
  end

  def write(str)
    puts "== #{str} ".ljust(80, '=') unless silent
  end

  def mute(value)
    @silent = value

    self
  end
end
