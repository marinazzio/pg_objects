RSpec.describe 'ParsedObject qualified_name' do # rubocop:disable RSpec/DescribeClass
  subject(:parsed_object) { PgObjects::ParsedObjectFactory.create_object(PgQuery.parse(source)) }

  context 'with a schema-qualified relation (table)' do
    let(:source) { 'CREATE TABLE myschema.users (id INT);' }

    it 'exposes the unqualified name' do
      expect(parsed_object.name).to eq('users')
    end

    it 'exposes the schema-qualified name' do
      expect(parsed_object.qualified_name).to eq('myschema.users')
    end
  end

  context 'with an unqualified relation (table)' do
    let(:source) { 'CREATE TABLE users (id INT);' }

    it 'falls back to the bare name for qualified_name' do
      expect(parsed_object.qualified_name).to eq('users')
    end
  end

  context 'with a schema-qualified list name (function)' do
    let(:source) { 'CREATE FUNCTION app.calc(a INTEGER) RETURNS INTEGER AS $$ SELECT 1; $$ LANGUAGE sql;' }

    it 'exposes the unqualified name' do
      expect(parsed_object.name).to eq('calc')
    end

    it 'exposes the schema-qualified name' do
      expect(parsed_object.qualified_name).to eq('app.calc')
    end
  end

  context 'with an unqualified list name (function)' do
    let(:source) { 'CREATE FUNCTION calc(a INTEGER) RETURNS INTEGER AS $$ SELECT 1; $$ LANGUAGE sql;' }

    it 'falls back to the bare name for qualified_name' do
      expect(parsed_object.qualified_name).to eq('calc')
    end
  end
end
