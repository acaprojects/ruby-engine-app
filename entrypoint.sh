#!/bin/bash
set -e

cd /home/aca-apps/ruby-engine-app
(ls -l ../Gemfile.lock.from-docker-build && cp -f ../Gemfile.lock.from-docker-build Gemfile.lock) || echo "Docker image's Gemfile.lock not found. Using engine repo's"

if [ "$1" == "engine" ]; then
    exec bundle exec sg -p 8080 -e production
elif [ "$1" == "engine-dev" ]; then
    exec bundle exec sg -p 8080 -e development
else
    # Else, just run the command that we were given
    exec "$@"
fi