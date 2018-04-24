#!/usr/bin/env bash

set -e

mkdir -p data/cert

echo "Creating new certificate..."

name=""
while getopts 'd:' flag; do
  case "${flag}" in
    n) name="${OPTARG}" ;;
  esac
done

if [ -z "$name" ]; then
    while read -p 'Pleas enter certificate name (if use domain as name consider including port number): ' name && [[ -z "$name" ]] ; do
        printf "Pleas type some value.\n"
    done
fi

# https://docs.docker.com/registry/insecure/#use-self-signed-certificates
# https://docs.docker.com/registry/deploying/#native-basic-auth
docker run -it -v `pwd`/data/cert:/export --name openssl \
    frapsoft/openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout "/export/$name.key" \
    -x509 -days 365 -out "/export/$name.crt" \
    -subj "/C=/ST=/L=/O= Name/OU=Org/CN=$name" \
    -nodes

sudo mkdir -p "/etc/docker/certs.d/$name"
sudo cp "data/cert/$name.crt" "/etc/docker/certs.d/$name/ca.crt"

release="$(lsb_release -is 2>/dev/null)"
release="${release,,}"

echo "Current linux release $release"
if [ "$release" == "ubuntu" ] ; then
    echo "Coping crt to Ubuntu certificates"
    sudo cp "data/cert/$name.crt" "/usr/local/share/ca-certificates/$name.crt"
    sudo update-ca-certificates
fi

echo "Certificate created in data/cert/"
