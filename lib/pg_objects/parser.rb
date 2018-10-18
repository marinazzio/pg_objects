module PgObjects
  class Parser
    class << self
      def fetch_dependencies(text)
        text.split("\n").select { |ln| ln =~ /^(--|#)!/ }.map { |ln| ln.split(' ')[1] if ln =~ /!depends_on/ }
      end
    end
  end
end
