##
# Console output
#
class PgObjects::Logger
  include Import['config']

  def write(str)
    puts "== #{str} ".ljust(80, '=') unless config.silent
  end
end
