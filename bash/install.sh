#!/usr/bin/env bash

set -e

prod=false
while getopts 'pe:' flag; do
  case "${flag}" in
    p) prod=true ;;
  esac
done

if [ -f bash/.install-lock ]; then
    echo "Project is already created. If you are sure you want to install it again pleas remove lock file bash/.install-lock. Exiting."
    exit 0
fi

if [ ! -f .env ]; then
    echo "Creating .env file..."
    touch .env
else
    echo "Loading .env file..."
    . .env
fi

echo "Starting installation of docker environment..."

if [ -z "$SYMFONY_APP_PATH" ] ; then
    SYMFONY_APP_PATH=$(pwd)
    echo "SYMFONY_APP_PATH=$SYMFONY_APP_PATH" >> .env
fi

if [ -z "$SYMFONY_APP_PORT" ] ; then
    read -p "Pleas enter Symfony application port (leave empty to use default 8090): " SYMFONY_APP_PORT
    if [ -z "$SYMFONY_APP_PORT" ]; then
        SYMFONY_APP_PORT="8090"
    fi
    echo "SYMFONY_APP_PORT=$SYMFONY_APP_PORT" >> .env
fi

if [ -z "$KIBANA_PORT" ] ; then
    read -p "Pleas enter Kibana application port (leave empty to use default 8091): " KIBANA_PORT
    if [ -z "$KIBANA_PORT" ]; then
        KIBANA_PORT="8091"
    fi
    echo "KIBANA_PORT=$KIBANA_PORT" >> .env
fi

if [ -z "$TIMEZONE" ] ; then
    while read -p 'Pleas enter your timezone: ' TIMEZONE && [[ -z "$TIMEZONE" ]] ; do
        printf "Pleas type some value.\n"
    done
    echo "TIMEZONE=$TIMEZONE" >> .env
fi

if [ -z "$POSTGRES_PASSWORD" ] ; then
    while read -p 'Pleas enter new password for Symfony application database: ' POSTGRES_PASSWORD && [[ -z "$POSTGRES_PASSWORD" ]] ; do
        printf "Pleas type some value.\n"
    done
    echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> .env
fi

if [ -z "$POSTGRES_USER" ] ; then
    while read -p 'Pleas enter new username for Symfony application database: ' POSTGRES_USER && [[ -z "$POSTGRES_USER" ]] ; do
        printf "Pleas type some value.\n"
    done
    echo "POSTGRES_USER=$POSTGRES_USER" >> .env
fi

if [ -z "$POSTGRES_DB" ] ; then
    while read -p 'Pleas enter new database name for Symfony application: ' POSTGRES_DB && [[ -z "$POSTGRES_DB" ]] ; do
        printf "Pleas type some value.\n"
    done
    echo "POSTGRES_DB=$POSTGRES_DB" >> .env
fi

if [ -z "$POSTGRES_PORT" ] ; then
    read -p "Pleas postgres port (leave empty to use default 5432): " POSTGRES_PORT
    if [ -z "$POSTGRES_PORT" ]; then
        POSTGRES_PORT="5432"
    fi
    echo "POSTGRES_PORT=$POSTGRES_PORT" >> .env
fi

# Install docker
echo "Docker installation..."
if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed. Skipping docker installation."
else
    # Install curl
    sudo apt-get --assume-yes install curl 2> /dev/null

    # Install docker
    # https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script
    curl -fsSL get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

    rm -f get-docker.sh

    # Manage as non root
    # https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user
    [ $(getent group docker) ] || sudo groupadd docker
    sudo usermod -aG docker $USER

    # Refresh current user groups to prevent need of log out
    # https://superuser.com/questions/272061/reload-a-linux-users-group-assignments-without-logging-out
    exec sg docker newgrp `id -gn`

    # Enable docker autostart
    # https://docs.docker.com/install/linux/linux-postinstall/#configure-docker-to-start-on-boot
    sudo systemctl enable docker

    echo "Docker installation finished."
fi

# Install docker compose
echo "Docker compose installation..."
if [ -x "$(command -v docker-compose)" ]; then
    echo "Docker compose is already installed. Skipping docker compose installation."
else
    # Install curl
    sudo apt-get --assume-yes install curl 2> /dev/null

    # https://docs.docker.com/compose/install/#install-compose
    sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Code completion
    # https://docs.docker.com/compose/completion/#bash
    sudo curl -L https://raw.githubusercontent.com/docker/compose/1.21.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

    echo "Docker compose installation finished."
fi

# Create local install lock
touch bash/.install-lock

sudo rm -f data/postgres/.gitkeep

echo "Installation of docker environment completed."

# Start project containers
if [ "$prod" = false ] ; then
    ./bash/manage.sh -a reload -c dev
else
    ./bash/manage.sh -a reload -c deploy
fi
