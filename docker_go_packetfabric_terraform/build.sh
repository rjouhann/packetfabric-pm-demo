#!/bin/bash

# do the gut pull on the branch is at and removing old branches
cd terraform-provider-packetfabric
git fetch
git status
git branch | grep -v $(git rev-parse --abbrev-ref HEAD) | xargs git branch -D
git pull
echo
cd -
# remove old docker image
docker rmi terraform-runner
# build the new one (--no-cache optional)
docker build -t terraform-runner .
# list the new image
docker images | grep terr