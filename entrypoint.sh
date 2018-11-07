#!/bin/bash
set -e

mv Gemfile.lock Gemfile.lock.from-git-repo
mv ../Gemfile.lock.from-docker-build Gemfile.lock

if [ "$1" == "engine" ]; then
    cd /home/aca-apps/ruby-engine-app
    exec bundle exec sg -p 8080 -e production

elif [ "$1" == "engine-dev" ]; then
    cd /home/aca-apps/ruby-engine-app
    exec bundle exec sg -p 8080 -e development

elif [ "$1" == "cotag" ]; then
    cd /home/aca-apps/cotag-api
    exec bundle exec sg -p 8080 -e production

elif [ "$1" == "tasks" ]; then
    cd /home/aca-apps/cotag-api
    exec bundle exec sidekiq -q default

elif [ "$1" == "processing" ]; then
    cd /home/aca-apps/cotag-api
    exec bundle exec sidekiq -q transcode -c $2
    
else
    # Else, just run the command that we were given
    exec "$@"
fi
