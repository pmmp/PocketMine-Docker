#!/bin/bash

# Expected files:
# PHP_Linux-x86_64.tar.gz
# PocketMine-MP.phar

# Expected env vars:
# TAG: the PocketMine-MP repo tag to build against
# WORKSPACE: the directory of the workspace containing the expected files

set -x
set -e

cd "$WORKSPACE"
tar xzf PHP_Linux-x86_64.tar.gz

curl -SsLO https://raw.githubusercontent.com/pmmp/PocketMine-MP/$TAG/start.sh

docker build -t pmmp/pocketmine-mp:${TAG} .
docker push pmmp/pocketmine-mp:${TAG}

docker build -t pmmp/pocketmine-mp:latest .
docker push pmmp/pocketmine-mp:latest
