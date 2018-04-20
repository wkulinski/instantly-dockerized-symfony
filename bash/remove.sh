#!/usr/bin/env bash

set -e

read -p "Are you sure you want remove ALL docker containers on machine? [Y/n]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

echo "Removing ALL docker containers on machine..."
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
echo "ALL docker containers removed."
