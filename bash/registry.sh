#!/usr/bin/env bash

set -e

# https://github.com/docker/docker.github.io/blob/master/registry/deploying.md
if [ "$1" == "install" ]; then
    echo "Docker registry installation..."
    if [ ! "$(docker ps -a | grep -w 'docker-registry-repo')" ]; then
        if [ ! -f .env ]; then
            echo "Creating .env file..."
            touch .env
        else
            echo "Loading .env file..."
            . .env
        fi

        if [ -z "$DOCKER_REGISTRY_PORT" ] ; then
            read -p "Pleas enter docker registry port (leave empty to use default 5000): " DOCKER_REGISTRY_PORT
            if [ -z "$DOCKER_REGISTRY_PORT" ]; then
                DOCKER_REGISTRY_PORT="5000"
            fi
            echo "DOCKER_REGISTRY_PORT=$DOCKER_REGISTRY_PORT" >> .env
        fi

        if [ -z "$DOCKER_REGISTRY_PATH" ] ; then
            while read -p 'Pleas enter registry domain/path (ie. localhost): ' DOCKER_REGISTRY_PATH && [[ -z "$DOCKER_REGISTRY_PATH" ]] ; do
                printf "Pleas type some value.\n"
            done
            echo "DOCKER_REGISTRY_PATH=$DOCKER_REGISTRY_PATH" >> .env
        fi

        if [ -z "$DOCKER_REGISTRY_USERNAME" ] ; then
            while read -p 'Pleas enter registry username: ' DOCKER_REGISTRY_USERNAME && [[ -z "$DOCKER_REGISTRY_USERNAME" ]] ; do
                printf "Pleas type some value.\n"
            done
            echo "DOCKER_REGISTRY_USERNAME=$DOCKER_REGISTRY_USERNAME" >> .env
        fi

        if [ -z "$DOCKER_REGISTRY_PASSWORD" ] ; then
            while read -p 'Pleas enter registry password: ' DOCKER_REGISTRY_PASSWORD && [[ -z "$DOCKER_REGISTRY_PASSWORD" ]] ; do
                printf "Pleas type some value.\n"
            done
            echo "DOCKER_REGISTRY_PASSWORD=$DOCKER_REGISTRY_PASSWORD" >> .env
        fi

        echo "Checking certificates..."
        registry_domain="$DOCKER_REGISTRY_PATH:$DOCKER_REGISTRY_PORT"
        if [ ! -f `pwd`"/data/cert/$registry_domain.crt" ] || [ ! -f `pwd`"/data/cert/$registry_domain.key" ]; then
            echo "Missing certificate data/cert/$registry_domain.crt, data/cert/$registry_domain.key..."
            ./bash/cert.sh -d "$registry_domain"
        else
            echo "Certificates ok."
        fi

        mkdir -p data/auth
        docker run --entrypoint htpasswd registry:2 -Bbn "$DOCKER_REGISTRY_USERNAME" "$DOCKER_REGISTRY_PASSWORD" > data/auth/htpasswd

        ./bash/manage.sh -a reload -c registry

        echo "Docker registry installation done."
    else
        echo "Docker registry is already installed. Skipping Docker registry installation."
    fi
elif [ "$1" == "install-ui" ]; then
    # https://hub.docker.com/r/konradkleine/docker-registry-frontend/
    echo "Docker registry user interface installation..."
    if [ ! "$(docker ps -a | grep docker-registry-ui)" ]; then
        if [ ! -f .env ]; then
            echo "Creating .env file..."
            touch .env
        else
            echo "Loading .env file..."
            . .env
        fi

        if [ -z "$DOCKER_REGISTRY_UI_PORT" ] ; then
            read -p "Pleas enter docker registry user interface port (leave empty to use default 5001): " DOCKER_REGISTRY_UI_PORT
            if [ -z "$DOCKER_REGISTRY_UI_PORT" ]; then
                DOCKER_REGISTRY_UI_PORT="5001"
            fi
            echo "DOCKER_REGISTRY_UI_PORT=$DOCKER_REGISTRY_UI_PORT" >> .env
        fi

        if [ -z "$DOCKER_REGISTRY_PORT" ] ; then
            registry_port=""
            if [ "$(docker ps -a | grep -w 'docker-registry-repo')" ]; then
                registry_port="$(docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}}{{end}}' docker-registry-repo)"

                read -p "Pleas enter docker registry port (leave empty to use $registry_port): " registry_port_custom
                if [ -z "$registry_port_custom" ]; then
                    echo "Using $registry_port"
                else
                    registry_port="$registry_port_custom"
                fi
            else
                while read -p 'Pleas enter docker registry address: ' registry_port && [[ -z "$registry_port" ]] ; do
                    printf "Pleas type some value.\n"
                done
            fi
            DOCKER_REGISTRY_PORT="$registry_port"
            echo "DOCKER_REGISTRY_PORT=$registry_port" >> .env
        fi

        if [ -z "$DOCKER_REGISTRY_IP_UI" ] ; then
            registry_path=""
            if [ "$(docker ps -a | grep -w 'docker-registry-repo')" ]; then
                registry_path="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' docker-registry-repo)"

                read -p "Pleas enter docker registry domain/path (leave empty to use detected registry gateway $registry_path - note that localhost probably will not work): " registry_path_custom
                if [ -z "$registry_path_custom" ]; then
                    echo "Using $registry_path"
                else
                    registry_path="$registry_path_custom"
                fi
            else
                while read -p "Pleas enter docker registry domain/path (note that localhost probably will not work): " registry_path && [[ -z "$registry_path" ]] ; do
                    printf "Pleas type some value.\n"
                done
            fi
            DOCKER_REGISTRY_IP_UI="$registry_path"
            echo "DOCKER_REGISTRY_IP_UI=$registry_path" >> .env
        fi

        ./bash/manage.sh -a reload -c registry-ui
    else
        echo "Docker registry user interface is already installed. Skipping Docker registry user interface installation."
    fi
else
    echo "Pleas define action."
fi