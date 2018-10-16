RSpec.describe PgObjects do

  it 'has a version number' do
    expect(PgObjects::VERSION).not_to be nil
  end

  it 'does not work unless adapter is pg' do
    # expect {}.to raise_error
  end
end
