#!/usr/bin/env bash

set -e

echo "Stopping docker containers..."
docker-compose down --remove-orphans
echo "Docker containers stopped."
