module PgObjects
  DEFAULT_VERSION = '0.0.0'

  VERSION = begin
    # Try to get version from git tag
    version = `git describe --tags --abbrev=0 2>/dev/null`.gsub(/^v/, '').strip
    version.empty? ? DEFAULT_VERSION : version
  rescue StandardError
    DEFAULT_VERSION
  end
end
