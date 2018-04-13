#!/usr/bin/env bash

set -e

./bash/hook/pre-build.sh

cd symfony/

git fetch

if [ "$1" != "--prod" ]; then
    echo "Checking out to production environment..."
    git checkout master
    git reset --hard origin/master
else
    echo "Checking out to developement environment..."
    git checkout develop
    git reset --hard origin/develop
fi
echo "Done."

echo "Removing cache..."
rm -Rf var/cache/*
echo "Cache removed."

./bash/reload.sh

./bash/hook/post-build.sh
