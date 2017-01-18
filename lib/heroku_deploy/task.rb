require "pp"
require "yaml"
require "rake"

module HerokuDeploy
  def self.heroku_deploy_config
    config_path = Rails.root + "config" + "heroku_deploy.yml"
    if config_path.exist?
      YAML.load_file(config_path) || {}
    else
      {}
    end
  end

  class Task
    include Rake::DSL

    attr_reader :heroku_app_names

    def initialize()
      define
    end

    def define
      desc "deploy CURRENT git branch to heroku"
      task :heroku_deploy, [:remote] do |t, args|
        config = HerokuDeploy.heroku_deploy_config

        remote_name = args[:remote]

        unless remote_name && ! remote_name.empty?
          $stderr.puts "\nNeed to supply a git remote name: `rake heroku_deploy[production]`"
          exit 1
        end

        migration_arguments = if (argument = config["extra_migration_arguments"])
          "--extra-migration-arguments=#{argument}"
        else
          ""
        end

        system_call = [HerokuDeploy::DEPLOY_SCRIPT_PATH, remote_name, migration_arguments, "2>&1"].compact

        $stderr.puts system_call.join(" ")

        Bundler.with_clean_env do
          success = system *system_call

          unless success
            $stderr.print "\nFAILED!\n\n"
          end
        end
      end
    end
  end
end
