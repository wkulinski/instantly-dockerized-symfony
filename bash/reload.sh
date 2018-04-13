#!/usr/bin/env bash

set -e

./bash/hook/pre-reload.sh

echo "Reloading docker containers..."
docker-compose down --remove-orphans
docker-compose build
docker-compose up -d
echo "Docker containers reloaded."

./bash/hook/post-reload.sh
