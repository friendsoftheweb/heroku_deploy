#!/usr/bin/env bash
#
# A heroku deploy script
#  * Pushes current branch in your working copy to heroku (default remote
#    called 'production')
#  * with checks to see if migrations need to be run, runs them if so.
#  * Some other sanity checks in there with y/n prompts.
#
#
# First arg is git remote name.
#
# If git remote name is "production", it will refuse to deploy any branch but master.
#
set -e

remote=$1

remote_url=$(git remote get-url $remote)

if [[ ! $remote_url == "https://git.heroku.com/"* ]]; then
  echo "  Remote does not look like a heroku url: $remote_url"
  exit 1
fi

heroku_app=$(basename "$remote_url" | sed 's/\.[^.]*$//')

current_branch=$(git rev-parse --abbrev-ref HEAD)

echo "== Deploying branch '$current_branch' to remote '$remote', heroku app '$heroku_app'..."

# Only master can be deployed to production
if [[ "$remote" == "production" && "$current_branch" != "master" ]]; then
  echo "  Can only deploy master branch to production, exiting."
  exit 1
fi

# Guard uncommitted local files
if [[ $(git status --porcelain --untracked-files=no -- | wc -l | tr -d " ") != '0' ]]  ; then
  git status --porcelain
  read -p "  There are uncommitted files. Deploy anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
    exit
  fi
fi

# Guard pushed to origin
if [[ $(git log origin/$current_branch...$current_branch -- | wc -l) -ne 0 ]] ; then
  read -p "  Local $current_branch does not match upstream, proceed anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
    exit
  fi
fi

function git_push {
  if [[ "$remote" = "production" ]] ; then
    git push production master
  else
    git push --force $remote $current_branch:master
  fi
}

if git remote | grep -q $remote; then
  if ! git diff --quiet $remote/master -- db/migrate; then
    read -p "  Migrations detected. Continue with migrate and deploy? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
      exit
    fi

    echo "  Migrations detected, deploying, enabling maintenance, restarting, and disabling maintenance..."
    git_push
    heroku maintenance:on -a $heroku_app
    if [[ $(heroku run rake db:migrate -x -s performance-l -a $heroku_app) ]] ; then
      sleep 4 # Wait a moment before restarting to prevent the "Could not restart error"
      heroku restart -a $heroku_app
    else
      echo "  !!Migrations failed!! Rolling back"
      heroku rollback -a $heroku_app
    fi
    heroku maintenance:off -a $heroku_app
  else
    echo "  No migrations detected, deploying..."
    git_push
  fi
else
  echo "  No git remote named '$remote'."
  exit 1
fi
