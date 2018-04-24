#!/usr/bin/env bash

set -e

mkdir -p data/cert

echo "Creating new certificate..."

domain=""
while getopts 'd:' flag; do
  case "${flag}" in
    d) domain="${OPTARG}" ;;
  esac
done

if [ -z "$domain" ]; then
    while read -p 'Pleas enter domain (with port if required): ' domain && [[ -z "$domain" ]] ; do
        printf "Pleas type some value.\n"
    done
fi

# https://docs.docker.com/registry/insecure/#use-self-signed-certificates
# https://docs.docker.com/registry/deploying/#native-basic-auth
docker run -it -v `pwd`/data/cert:/export --name openssl \
    frapsoft/openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout "/export/$domain.key" \
    -x509 -days 365 -out "/export/$domain.crt" \
    -subj "/C=/ST=/L=/O= Name/OU=Org/CN=$domain" \
    -nodes

sudo mkdir -p "/etc/docker/certs.d/$domain"
sudo cp "data/cert/$domain.crt" "/etc/docker/certs.d/$domain/ca.crt"

release="$(lsb_release -is 2>/dev/null)"
release="${release,,}"

echo "Current linux release $release"
if [ "$release" == "ubuntu" ] ; then
    echo "Coping crt to Ubuntu certificates"
    sudo cp "data/cert/$domain.crt" "/usr/local/share/ca-certificates/$domain.crt"
    sudo update-ca-certificates
fi

echo "Certificate created in data/cert/"
