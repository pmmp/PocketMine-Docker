#!/bin/bash

echo "Installing prerequisites.."

sudo apt-get --yes --force-yes update -y
sudo apt-get --yes --force-yes install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker Engine"

sudo apt-get --yes --force-yes update
sudo apt-get --yes --force-yes install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Docker installed successfully"

echo "Installing PocketMine-MP"
curl -s https://raw.githubusercontent.com/TobiasGrether/PocketMine-Docker/master/pocketmine-mp/docker-compose.yml -o docker-compose.yml
docker compose pull
mkdir data plugins
chmod 777 data plugins
echo "##########################################"
echo "Server is ready to go! To start it up, just run ./boot.sh, to restart it, run ./restart.sh and to stop it, run ./stop.sh"
echo "Plugins can be put in the plugins/ directory and server data can be found in data/"
echo "##########################################"
