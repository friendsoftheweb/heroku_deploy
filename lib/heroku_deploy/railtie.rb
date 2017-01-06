module HerokuDeploy
  class Railtie < Rails::Railtie
    rake_tasks do
      HerokuDeploy::Task.new
    end
  end
end
