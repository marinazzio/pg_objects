# A module that provides a method to load configuration settings from a YAML file.
module YamlConfigurable
  # Loads configuration settings from a YAML file.
  #
  # @param file_path [String] The path to the YAML file.
  def load_from_yaml(file_path)
    return unless File.exist?(file_path)

    settings_from(YAML.load_file(file_path)).each do |key, value|
      set_if_present(config, key, value)
    end
  rescue Psych::SyntaxError => e
    warn "[pg_objects] Ignoring malformed YAML config #{file_path}: #{e.message}"
  end

  private

  # Maps configuration keys to their values in the parsed YAML hash.
  def settings_from(config_hash)
    {
      before_path: config_hash.dig('directories', 'before'),
      after_path: config_hash.dig('directories', 'after'),
      extensions: config_hash['extensions'],
      silent: config_hash['silent'],
      transactional: config_hash['transactional'],
      auto_hook_migrations: config_hash['auto_hook_migrations']
    }
  end

  # Applies the value unless it is nil or an empty string/array. Booleans
  # (including +false+) have no +empty?+ and are always applied.
  def set_if_present(config, key, value)
    return if value.nil?
    return if value.respond_to?(:empty?) && value.empty?

    config.public_send("#{key}=", value)
  end
end
