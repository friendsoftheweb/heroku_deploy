# HerokuDeploy

Script to deploy a rails application to Heroku. Includes some safety checks, pushing to
Heroku via git, temporarily enabling maintenance mode, and running migrations (if
necessary).

The script is packed in a gem so that in a simple Rails application, it can be used just
by inclusion in your gem file.


## Basic Usage

Include the gem in your Gemfile:

    group :development do
      gem "heroku_deploy", git: "https://github.com/friendsoftheweb/heroku_deploy.git"
      # ...
    end

Ensure you have a Heroku git remote.

Run the script (assuming Rails 5):

    $ bin/rails heroku_deploy[remote_name]


## Configuration

To target a particular remote, specify the name when calling the rake task. For example:

    $ bin/rails heroku_deploy[staging]


To adjust the settings for migrations, create a configuration file at
`./config/heroku_deploy.yml`. The only supported option is for additional options for the
Heroku migration command `extra_migration_arguments`.

    # additional arguments added to `heroku run db:migrate ...`
    extra_migration_arguments: "-s performance-l"


# Safety Checks

Before deploying, a few safety checks are run.

* If you have uncommitted changes or your `origin` is not up to date, you will be warned
before continuing.
* If migrations need to be run, you'll be asked to confirm before maintenance mode is
enabled.
* If your remote name is `production` you must push from `master`.



# TODOs & Considerations

* Rewrite the bash script in Ruby. This may make it easier to maintain and expand to more
clearly handle errors.

* Currently this is deployed as a Ruby Gem. Alternatively this could be a generic utility,
globally installed. Because most of our projects have an identical configuration, the
current implementation is convenient.



