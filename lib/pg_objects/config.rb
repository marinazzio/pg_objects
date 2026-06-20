require_relative 'yaml_configurable'

module PgObjects
  ##
  # Use to set custom configuration:
  #
  #   PgObjects.configure do |config|
  #     # use relative from RAILS_ROOT
  #     config.before_path = 'db/alternate/before'
  #     # or full
  #     config.after_path = '/var/tmp/alternate/after'
  #     config.extensions = ['sql', 'txt']
  #     # suppress output to console
  #     config.silent = true
  #   end
  class << self
    def configure
      yield Config.config
    end

    def config
      Config.config
    end
  end

  class Config
    extend Dry::Configurable
    extend YamlConfigurable

    setting :before_path, default: 'db/objects/before'
    setting :after_path, default: 'db/objects/after'
    setting :extensions, default: ['sql']
    setting :silent, default: false

    # Master switch for the Rake hooks. When false, no hooks are installed and
    # objects are created only by invoking db:create_objects:before / :after
    # manually. Default true for backward compatibility.
    setting :auto_hook_migrations, default: true

    # Rake tasks that trigger object creation, mapped to the stages they run.
    # +:before+ creates objects from the "before" folder ahead of the task,
    # +:after+ creates objects from the "after" folder once the task finishes.
    # Override (or empty) this to opt out. db:rollback is intentionally absent
    # (a rollback should not recreate objects).
    setting :hook_tasks, default: {
      'db:migrate' => %i[before after],
      'db:schema:load' => %i[after],
      'db:migrate:redo' => %i[before after]
    }

    load_from_yaml 'config/pg_objects.yml'
  end
end
