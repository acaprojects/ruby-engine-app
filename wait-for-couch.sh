#!/bin/bash 
 
if [ "$1" == "engine" ]; then 
        couchup=1 
 
        while [ "$couchup" -gt 0 ]; do 
          >&2 echo "Waiting for Couch to become available - wait-for-couch.sh" 
          echo $couchup 
          sleep 1 
          couchup=`curl -s -u admin:$COUCHBASE_PASSWORD http://couch:8091/pools/default/buckets | grep -c  
unhealthy`; 
          couchup="$(($couchup + 0))" 
          echo $couchup 
        done 
 
        >&2 echo "Couch is up - starting engine" 
        cd /home/aca-apps/ruby-engine-app 
        set -e 
        exec bundle exec sg -p 8080 -e production 
else 
        exec "$@" 
fi
