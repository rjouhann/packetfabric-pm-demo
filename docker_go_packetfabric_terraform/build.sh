#!/bin/bash

cd terraform-provider-packetfabric
git fetch
git status
git branch | grep -v $(git rev-parse --abbrev-ref HEAD) | xargs git branch -D
git pull
echo
cd -
docker rmi terraform-runner
docker build -t terraform-runner .
docker images | grep terr