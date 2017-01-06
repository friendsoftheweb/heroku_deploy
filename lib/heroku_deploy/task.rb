require "pp"

module HerokuDeploy
  class Task
    include Rake::DSL

    attr_reader :heroku_app_names

    def initialize()
      define
    end

    def define
      desc "deploy CURRENT git branch to heroku"
      task :heroku_deploy, [:remote] do |t, args|
        remote_name = args[:remote]

        unless remote_name && ! remote_name.empty?
          $stderr.puts "\nNeed to supply a git remote name: `rake heroku_deploy[production]`"
          exit 1
        end

        system_call = [HerokuDeploy::DEPLOY_SCRIPT_PATH, remote_name, "2>&1"]

        $stderr.puts system_call.join(" ")

        success = system *system_call

        unless success
          $stderr.print "\nFAILED!\n\n"
        end
      end
    end
  end
end
