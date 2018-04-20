#!/usr/bin/env bash

set -e

if [ ! -f bash/.create-lock ]; then
    echo "Project has to be created first."
    exit 1;
fi

./bash/hook/pre-build.sh "$@"

#cd symfony/

prod=false
version=""
fetch=true
while getopts 'pv:n' flag; do
    case "${flag}" in
        p) prod=true ;;
        v) version="${OPTARG}" ;;
        n) fetch=false ;;
    esac
done

if [ "$fetch" == true ] ; then
    echo "Fetching remote repository..."
    git fetch

    if [ "$prod" = false ] ; then
        version="dev"

        echo "Checking out to developement environment..."
        git checkout develop
        git reset --hard origin/develop
    else
        if [ -z "$version" ]; then
            while read -p 'Pleas enter version number: ' version && [[ -z "$version" ]] ; do
                printf "Pleas type some value.\n"
            done
        fi

        echo "Checking out to production environment..."
        git checkout master
        git reset --hard origin/master
    fi
    echo "Done."
fi

#echo "Updating .env file..."
#if grep -Fxq "APPLICATION_VERSION=" .env
#then
#    sed -i "s/APPLICATION_VERSION=.*/APPLICATION_VERSION=$version/" .env
#else
#    echo "APPLICATION_VERSION=$version" >> .env
#fi
#echo ".env file updated."

echo "Removing cache..."
rm -Rf symfony/var/cache/*
echo "Cache removed."

#cd ../

echo "Building images..."
APPLICATION_VERSION="$version" docker-compose -f docker-compose.build.yml build
echo "Images build finished."

echo "Installing vendors..."
COMPOSER_ALLOW_SUPERUSER=1 docker-compose -f docker-compose.build.yml run --rm app composer install --no-interaction --classmap-authoritative --optimize-autoloader
#chown -R www-data:www-data .
echo "Vendors installed."

echo "Building app image..."
APPLICATION_VERSION="$version" docker-compose -f docker-compose.build.yml build app
echo "App image build finished."

source .env

if [ -z "$PRIVATE_DOCKER_REGISTRY_PATH" ] ; then
    while read -p 'Pleas enter registry path: ' registry_path && [[ -z "$registry_path" ]] ; do
        printf "Pleas type some value.\n"
    done

    echo "Updating .env file..."
    if grep -Fxq "PRIVATE_DOCKER_REGISTRY_PATH=" .env
    then
        sed -i "s/PRIVATE_DOCKER_REGISTRY_PATH=.*/PRIVATE_DOCKER_REGISTRY_PATH=$registry_path/" .env
    else
        echo "PRIVATE_DOCKER_REGISTRY_PATH=$registry_path" >> .env
    fi
    echo ".env file updated."

    PRIVATE_DOCKER_REGISTRY_PATH="$registry_path"
fi

echo "Login to $PRIVATE_DOCKER_REGISTRY_PATH registry path."
docker login "$PRIVATE_DOCKER_REGISTRY_PATH"

echo "Pushing to registry..."
APPLICATION_VERSION="$version" docker-compose -f docker-compose.build.yml push
echo "Push finished."

#APPLICATION_VERSION="$version" docker-compose -f docker-compose.build.yml bundle -o build/artifact.dab

#echo "Cleaning builds..."
#docker-compose -f docker-compose.build.yml down --rmi all

echo "Build finished."


#./bash/reload.sh "$@"

#./bash/hook/post-build.sh "$@"
