#!/usr/bin/env bash

set -e

# https://github.com/docker/docker.github.io/blob/master/registry/deploying.md
if [ "$1" == "install" ]; then
    echo "Docker registry installation..."
    if [ ! "$(docker ps -a | grep -w 'docker-registry-repo')" ]; then
        read -p "Pleas enter docker registry port (leave empty to use default 5000): " docker_registry_port
        if [ -z "$docker_registry_port" ]; then
            docker_registry_port="5000"
        fi

        while read -p 'Pleas enter registry username: ' registry_username && [[ -z "$registry_username" ]] ; do
            printf "Pleas type some value.\n"
        done

        while read -p 'Pleas enter registry password: ' registry_password && [[ -z "$registry_password" ]] ; do
            printf "Pleas type some value.\n"
        done

        while read -p 'Pleas enter registry domain: ' registry_domain && [[ -z "$registry_domain" ]] ; do
            printf "Pleas type some value.\n"
        done

        echo "Checking certificates..."
        if [ -f `pwd`"/data/cert/$registry_domain.crt" ] || [ -f `pwd`"/data/cert/$registry_domain.key" ]; then
            echo "Missing certificate data/cert/$registry_domain.crt, data/cert/$registry_domain.key..."
            ./bash/cert.sh -d "$registry_domain"
        else
            echo "Certificates ok."
        fi

        mkdir -p data/auth
        docker run --entrypoint htpasswd registry:2 -Bbn "$registry_username" "$registry_password" > data/auth/htpasswd

        docker volume create docker_registry_data
#        docker run -d -p "$docker_registry_port":5000 -v docker_registry_data:/var/lib/registry -v data/auth:/auth -e "SEARCH_BACKEND=true" --restart always --name docker-registry-repo registry:2

        docker run -d \
            -p "$docker_registry_port":5000 \
            --restart=always \
            --name docker-registry-repo \
            -v docker_registry_data:/var/lib/registry \
            -e "SEARCH_BACKEND=true" \
            -v `pwd`/data/auth:/auth \
            -e "REGISTRY_AUTH=htpasswd" \
            -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
            -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
            -v `pwd`/data/cert:/certs \
            -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/$registry_domain.crt" \
            -e "REGISTRY_HTTP_TLS_KEY=/certs/$registry_domain.key" \
            registry:2

        echo "Docker registry installation done."
    else
        echo "Docker registry is already installed. Skipping Docker registry installation."
    fi
elif [ "$1" == "install-ui" ]; then
    # https://hub.docker.com/r/konradkleine/docker-registry-frontend/
    echo "Docker registry user interface installation..."
    if [ ! "$(docker ps -a | grep docker-registry-ui)" ]; then
        read -p "Pleas enter docker registry user interface port (leave empty to use default 5001): " docker_registry_ui_port
        if [ -z "$docker_registry_ui_port" ]; then
            docker_registry_ui_port="5001"
        fi

        registryip=""
        if [ "$(docker ps -a | grep -w 'docker-registry-repo')" ]; then
            registryip="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-registry-repo)"

            read -p "Pleas enter docker registry address (leave empty to use $registryip): " registryipcustom
            if [ -z "$registryipcustom" ]; then
                echo "Using $registryip"
            else
                registryip="$registryipcustom"
            fi
        else
            while read -p 'Pleas enter docker registry address: ' registryip && [[ -z "$registryip" ]] ; do
                printf "Pleas type some value.\n"
            done
        fi

        registryport=""
        if [ "$(docker ps -a | grep -w 'docker-registry-repo')" ]; then
            registryport="$(docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}}{{end}}' docker-registry-repo)"

            read -p "Pleas enter docker registry port (leave empty to use $registryport): " registryportcustom
            if [ -z "$registryportcustom" ]; then
                echo "Using $registryport"
            else
                registryport="$registryportcustom"
            fi
        else
            while read -p 'Pleas enter docker registry address: ' registryport && [[ -z "$registryport" ]] ; do
                printf "Pleas type some value.\n"
            done
        fi

        docker run -d --restart always --name docker-registry-ui \
        -e "ENV_DOCKER_REGISTRY_HOST=$registryip" \
        -e "ENV_DOCKER_REGISTRY_PORT=$registryport" \
        -e ENV_DOCKER_REGISTRY_USE_SSL=1 \
        -p "$docker_registry_ui_port":80 \
        konradkleine/docker-registry-frontend:v2

#        docker run -d -p "$docker_registry_ui_port":8080 -e "REG1=http://$registryip/v2/" --restart always --name docker-registry-ui atcol/docker-registry-ui
    else
        echo "Docker registry user interface is already installed. Skipping Docker registry user interface installation."
    fi
elif [ "$1" == "stop" ]; then
    echo "Stopping docker registry..."
    docker container stop docker-registry-repo
    echo "Done."
elif [ "$1" == "stop-ui" ]; then
    echo "Stopping docker registry user interface..."
    docker container stop docker-registry-ui
    echo "Done."
elif [ "$1" == "remove" ]; then
    echo "Removing docker registry..."
    docker container stop docker-registry-repo && docker container rm -v docker-registry-repo
    echo "Done."
elif [ "$1" == "remove-ui" ]; then
    echo "Removing docker registry user interface..."
    docker container stop docker-registry-ui && docker container rm -v docker-registry-ui
    echo "Done."
else
    echo "Pleas define action."
fi