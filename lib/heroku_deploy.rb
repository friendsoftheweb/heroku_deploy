require "heroku_deploy/version"
require 'heroku_deploy/task'
module HerokuDeploy
  DEPLOY_SCRIPT_PATH = File.expand_path File.join(__FILE__, '../../scripts/deploy.sh')
end
