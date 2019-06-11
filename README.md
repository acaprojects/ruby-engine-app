# ACAEngine

https://docs.acaengine.com/

Docker Image available at: https://hub.docker.com/r/aca0/engine/

Branch | Build Status
--- | ---
Stable | [![Codefresh build status]( https://g.codefresh.io/api/badges/build?repoOwner=acaprojects&repoName=ruby-engine-app&branch=stable&pipelineName=engine&accountName=wille&type=cf-2)]( https://g.codefresh.io/repositories/acaprojects/ruby-engine-app/builds?filter=trigger:build;branch:stable;service:59ad40b29a3c76000121aa42~engine)
Master | [![Codefresh build status]( https://g.codefresh.io/api/badges/build?repoOwner=acaprojects&repoName=ruby-engine-app&branch=master&pipelineName=engine&accountName=wille&type=cf-2)]( https://g.codefresh.io/repositories/acaprojects/ruby-engine-app/builds?filter=trigger:build;branch:master;service:59ad40b29a3c76000121aa42~engine)
Dev | [![Codefresh build status]( https://g.codefresh.io/api/badges/build?repoOwner=acaprojects&repoName=ruby-engine-app&branch=dev&pipelineName=engine&accountName=wille&type=cf-2)]( https://g.codefresh.io/repositories/acaprojects/ruby-engine-app/builds?filter=trigger:build;branch:dev;service:59ad40b29a3c76000121aa42~engine)


### Updating forks from this repo ###
In your fork:
```
git remote add ruby-engine-app https://github.com/acaprojects/ruby-engine-app.git
git remote set-url --push ruby-engine-app no-pushing-allowed  #Just to ensure you don't push your private fork to this public repo
git pull -X theirs ruby-engine-app stable #OR master
git push origin master
```
 
