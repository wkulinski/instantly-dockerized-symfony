#!/usr/bin/env bash

set -e

./bash/hook/pre-reload.sh "$@"

prod=false
while getopts 'p' flag; do
  case "${flag}" in
    p) prod=true ;;
  esac
done

echo "Reloading docker containers..."

docker-compose down --remove-orphans
docker-compose build

if [ "$prod" = false ] ; then
    echo "Using default docker-compose"
    docker-compose up -d
else
    echo "Using production docker-compose"
    docker-compose -f docker-compose.prod.yml up -d
fi

echo "Docker containers reloaded."

./bash/hook/post-reload.sh "$@"
