# frozen_string_literal: true

##
# Console output with severity levels. Writes to the injected +stream+
# (default +$stdout+). With +config.silent+ enabled, +info+/+warn+ messages
# are suppressed; +error+ messages are always written.
class PgObjects::Logger
  include Import['config']

  def initialize(stream: $stdout, **deps)
    super(**deps)
    @stream = stream
  end

  # Backward-compatible entry point; behaves like +info+.
  def write(str)
    log(str)
  end

  def info(str)
    log(str)
  end

  def warn(str)
    log("[WARN] #{str}")
  end

  def error(str)
    log("[ERROR] #{str}", force: true)
  end

  private

  attr_reader :stream

  def log(str, force: false)
    return if config.silent && !force

    stream.puts "== #{str} ".ljust(80, '=')
  end
end
