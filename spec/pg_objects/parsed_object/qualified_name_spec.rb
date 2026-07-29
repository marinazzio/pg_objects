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

  context 'with a schema-qualified enum type' do
    let(:source) { "CREATE TYPE app.mood AS ENUM ('sad', 'ok');" }

    it 'exposes the schema-qualified name' do
      expect(parsed_object.qualified_name).to eq('app.mood')
    end
  end

  context 'with a schema-qualified range type' do
    let(:source) { 'CREATE TYPE app.floatrange AS RANGE (subtype = float8);' }

    it 'exposes the schema-qualified name' do
      expect(parsed_object.qualified_name).to eq('app.floatrange')
    end
  end

  context 'with a schema-qualified base type' do
    let(:source) { 'CREATE TYPE app.base_t (INPUT = in_func, OUTPUT = out_func);' }

    it 'exposes the schema-qualified name' do
      expect(parsed_object.qualified_name).to eq('app.base_t')
    end
  end

  context 'with a schema-qualified domain' do
    let(:source) { 'CREATE DOMAIN app.posint AS integer;' }

    it 'exposes the schema-qualified name' do
      expect(parsed_object.qualified_name).to eq('app.posint')
    end
  end

  context 'with a schema-qualified sequence' do
    let(:source) { 'CREATE SEQUENCE app.serial_seq;' }

    it 'exposes the schema-qualified name' do
      expect(parsed_object.qualified_name).to eq('app.serial_seq')
    end
  end

  context 'with an index on a schema-qualified table' do
    let(:source) { 'CREATE INDEX idx_users_email ON app.users (email);' }

    it 'exposes the name qualified by the indexed table schema' do
      expect(parsed_object.qualified_name).to eq('app.idx_users_email')
    end
  end

  context 'with an index on an unqualified table' do
    let(:source) { 'CREATE INDEX idx_users_email ON users (email);' }

    it 'falls back to the bare name for qualified_name' do
      expect(parsed_object.qualified_name).to eq('idx_users_email')
    end
  end
end
