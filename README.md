# HerokuDeploy

Logic to deploy to heroku in the FTW way.

It's a bit hacky and def doesn't take care of all edge cases and possible
error conditions, but the first step is getting it in a gem so diff
projects can share it, so we can make improvements worthwhile.

* checks to see if migrations need to be run, runs them if so, with maintenance
  mode and restart.
* Tries some other sanity checks, including try to ensure your code has been
  pushed to origin before you can deploy it to heroku.

1. Add the gem to Gemfile

        group :development do
           gem 'heroku_deploy', git: "git@github.com:friendsoftheweb/heroku_deploy.git"
        end

2. Add task to your `Rakefile`

        HerokuDeploy::Task.new

    We've done it this way cause anticipate in the future diff
    apps might have different config params, and this is one way to
    provide for that.

3. Make sure you have a heroku remote in your git checkout

4. Call the rake task with remote name:

        ./bin/rake heroku_deploy[remote_name]

   If you use the name `production` for your remote, then
   the script will not let you push any branch but `master` to it.


### to do ideas

* Rewrite all that bash in plain ruby to be less hairy?

* Should this be in the gemfile or at all, or just a generic
  utility you have installed on your machine? What if it needs
  project-specific config? Look in current directory for a `.deploy-config`
  file or something?  Would it be bad that an app can't insist on
  a certain version, or good that you update on your machine
  once and get new version for all your projects?

