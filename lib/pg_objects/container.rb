# frozen_string_literal: true

class PgObjects::Container
  extend ::Dry::Container::Mixin

  register 'config' do
    PgObjects::Config.new
  end

  register 'parser' do
    PgObjects::Parser.new
  end

  register 'logger' do
    PgObjects::Logger.new
  end
end

Import = Dry::AutoInject(PgObjects::Container)
