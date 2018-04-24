#!/usr/bin/env bash

set -e

if [ ! -f bash/.create-lock ]; then
    echo "Project has to be created first."
    exit 1;
fi

./bash/hook/pre-build.sh "$@"

prod=false
version=""
fetch=false
while getopts 'pv:n' flag; do
    case "${flag}" in
        p) prod=true ;;
        v) version="${OPTARG}" ;;
        f) fetch=true ;;
    esac
done

. .env

if [ -z "$PRIVATE_DOCKER_REGISTRY_PATH" ] ; then
    while read -p 'Pleas enter registry path: ' PRIVATE_DOCKER_REGISTRY_PATH && [[ -z "$PRIVATE_DOCKER_REGISTRY_PATH" ]] ; do
        printf "Pleas type some value.\n"
    done

    echo "Updating .env file..."
    echo "PRIVATE_DOCKER_REGISTRY_PATH=$PRIVATE_DOCKER_REGISTRY_PATH" >> .env
    echo ".env file updated."
fi

echo "Preparing build and push to $PRIVATE_DOCKER_REGISTRY_PATH"

if [ -z "$version" ] ; then
    if [ "$prod" = false ] ; then
        version="dev"
    else
        while read -p 'Pleas enter version number: ' version && [[ -z "$version" ]] ; do
            printf "Pleas type some value.\n"
        done
    fi
fi

if [ "$fetch" == true ] ; then
    echo "Fetching remote repository..."
    git fetch

    if [ "$prod" = false ] ; then
        echo "Checking out to developement environment..."
        git checkout develop
        git reset --hard origin/develop
    else
        echo "Checking out to production environment..."
        git checkout master
        git reset --hard origin/master
    fi
    echo "Done."
fi

echo "Removing cache..."
rm -Rf symfony/var/cache/*
echo "Cache removed."

project_name="${PWD##*/}-build"

echo "Building images..."
APPLICATION_VERSION="$version" docker-compose \
    -p "$project_name" \
    -f docker-compose.yml \
    -f ./compose/docker-compose.build.yml \
    build
echo "Images build finished."

echo "Installing vendors..."
COMPOSER_ALLOW_SUPERUSER=1 docker-compose \
    -p "$project_name" \
    -f docker-compose.yml \
    -f ./compose/docker-compose.build.yml \
    run --rm app composer install --no-interaction --classmap-authoritative --optimize-autoloader
echo "Vendors installed."

echo "Re-building app image..."
APPLICATION_VERSION="$version" docker-compose \
    -p "$project_name" \
    -f docker-compose.build.yml \
    -f ./compose/docker-compose.build.yml \
    build app
echo "App image build finished."

echo "Login to $PRIVATE_DOCKER_REGISTRY_PATH registry path."
docker login "$PRIVATE_DOCKER_REGISTRY_PATH"

echo "Pushing to registry..."
APPLICATION_VERSION="$version" docker-compose \
    -p "$project_name" \
    -f docker-compose.build.yml \
    -f ./compose/docker-compose.build.yml \
    push
echo "Push finished."

echo "Build finished."

./bash/hook/post-build.sh "$@"
