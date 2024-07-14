# A module that provides a method to load configuration settings from a YAML file.
module YamlConfigurable
  # Loads configuration settings from a YAML file.
  #
  # @param file_path [String] The path to the YAML file.
  def load_from_yaml(file_path)
    return unless File.exist?(file_path)

    config_hash = YAML.load_file(file_path)

    set_if_present(config, :before_path, config_hash.dig('directories', 'before'))
    set_if_present(config, :after_path, config_hash.dig('directories', 'after'))
    set_if_present(config, :extensions, config_hash['extensions'])
    set_if_present(config, :silent, config_hash['silent'])
  end

  private

  def set_if_present(config, key, value)
    config.public_send("#{key}=", value) if value.present?
  end
end
