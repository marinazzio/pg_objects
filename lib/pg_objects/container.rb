# frozen_string_literal: true

##
# Container for dependencies
#
class PgObjects::Container
  extend ::Dry::Container::Mixin

  register 'config' do
    PgObjects::Config.config
  end

  register 'db_object_factory' do
    PgObjects::DbObjectFactory.new
  end

  register 'parsed_object_factory' do
    PgObjects::ParsedObjectFactory
  end

  register 'parser' do
    PgObjects::Parser.new
  end

  register 'logger' do
    PgObjects::Logger.new
  end
end

Import = Dry::AutoInject(PgObjects::Container)
