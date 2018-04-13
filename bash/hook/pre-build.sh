#!/usr/bin/env bash

echo "Pre build hook"

# Enable maintenance mode but redirect errors to null in case if it was first build and project files don't exists
docker-compose exec php php bin/console app:maintenance --enable 2> /dev/null

echo "Pre build hook finish."
