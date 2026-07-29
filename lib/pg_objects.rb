# frozen_string_literal: true

require_relative 'pg_objects/version'

module PgObjects
  # Raised when a dependency name resolves to more than one object. Carries
  # the matching objects' file paths via +candidates+ and the file that
  # declared the dependency via +referrer+; the message lists them all. Also
  # accepts a bare name for compatibility.
  class AmbiguousDependencyError < StandardError
    attr_reader :candidates, :referrer

    def initialize(dep_name = nil, candidates: [], referrer: nil)
      @candidates = candidates
      @referrer = referrer
      message = build_message(dep_name)
      message.empty? ? super() : super(message)
    end

    private

    def build_message(dep_name)
      message = dep_name.to_s
      message += " (referenced by #{referrer})" if referrer
      message += " matches: #{candidates.join(', ')}" unless candidates.empty?
      message
    end
  end

  # Raised when object dependencies form a cycle. Carries the resolution chain
  # that closed the cycle (e.g. ["a", "b", "a"]) via +cycle_path+; the message
  # renders it as "a -> b -> a". Also accepts a single name for compatibility.
  class CyclicDependencyError < StandardError
    attr_reader :cycle_path

    def initialize(cycle_path = nil)
      @cycle_path = Array(cycle_path)
      @cycle_path.empty? ? super() : super(@cycle_path.join(' -> '))
    end
  end

  # Raised when a declared dependency matches no loaded object. Carries the
  # file that declared the dependency via +referrer+ and includes it in the
  # message. Also accepts a bare name for compatibility.
  class DependencyNotExistError < StandardError
    attr_reader :referrer

    def initialize(dep_name = nil, referrer: nil)
      @referrer = referrer
      message = dep_name.to_s
      message += " (referenced by #{referrer})" unless referrer.to_s.empty?
      message.empty? ? super() : super(message)
    end
  end

  class UnsupportedAdapterError < StandardError; end
  class UnknownObjectTypeError < StandardError; end
  class MalformedStatementError < StandardError; end
end

require 'pg_objects/railtie' if defined?(Rails)

require 'dry-configurable'
require 'dry-container'
require 'dry-auto_inject'
require 'memery'

require 'pg_objects/container'
require 'pg_objects/config'
require 'pg_objects/db_object'
require 'pg_objects/db_object_factory'
require 'pg_objects/logger'
require 'pg_objects/manager'
require 'pg_objects/parsed_object'
require 'pg_objects/parser'
