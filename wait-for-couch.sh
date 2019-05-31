#!/bin/bash

couchAddr="couch"

if [ "$1" == "engine" ]; then
        unhealthyCount=1

        while [ "$unhealthyCount" -gt 0 -o "$couchStatus" != "200" ]; do
          >&2 echo "Waiting for Couch to become available and healthy"
          
          sleep 1
          
          unhealthyCount=`curl -s -u admin:$COUCHBASE_PASSWORD http://$couchAddr:8091/pools/default/buckets | grep -c unhealthy`;
          unhealthyCount="$(($unhealthyCount + 0))"
          echo $unhealthyCount
          
          couchStatus=`curl --write-out %{http_code} --output /dev/null -s -u admin:$COUCHBASE_PASSWORD http://$couchAddr:8091/pools/default/buckets`
          
          if [ "$unhealthyCount" -gt 0 ]; then
            echo "Couch unhealthy."
          fi
          
          if [ "$couchstatus" != "200" ]; then
            echo "Couch response status: ${couchStatus}"
          fi
          
        done

        >&2 echo "Couch is up - starting engine"
        cd /home/aca-apps/ruby-engine-app
        set -e
        exec bundle exec sg -p 8080 -e production
else
        exec "$@"
fi
