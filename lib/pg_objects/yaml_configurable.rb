module YamlConfigurable
  def load_from_yaml(file_path)
    return unless File.exist?(file_path)

    config_hash = YAML.load_file(file_path)

    set_if_present(config, :before_path, config_hash.dig('directories', 'before'))
    set_if_present(config, :after_path, config_hash.dig('directories', 'after'))
    set_if_present(config, :extensions, config_hash.dig('extensions'))
    set_if_present(config, :silent, config_hash.dig('silent'))
  end

  def set_if_present(config, key, value)
    config.public_send("#{key}=", value) if value.present?
  end
end
