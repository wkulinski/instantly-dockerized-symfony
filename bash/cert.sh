#!/usr/bin/env bash

set -e

mkdir -p data/cert

echo "Creating new certificate..."

#email=""
domain=""
while getopts 'd:' flag; do
  case "${flag}" in
#    e) email="${OPTARG}" ;;
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

#
#if [ -z "$email" ]; then
#    while read -p 'Pleas enter email: ' email && [[ -z "$email" ]] ; do
#        printf "Pleas type some value.\n"
#    done
#fi
#
#if [ -z "$domain" ]; then
#    while read -p 'Pleas enter domain: ' domain && [[ -z "$domain" ]] ; do
#        printf "Pleas type some value.\n"
#    done
#fi

#To fix these errors, please make sure that your domain name was
#entered correctly and the DNS A/AAAA record(s) for that domain
#contain(s) the right IP address.

#docker run -it --rm --name certbot \
#    -v `pwd`/data/letsencrypt/cert:/etc/letsencrypt \
#    -v `pwd`/data/letsencrypt/lib:/var/lib/letsencrypt \
#    certbot/certbot certonly \
#    --standalone \
#    --email "$email" \
#    -d "$domain"
#
#echo "CA certificate installed in data/letsencrypt/cert/live"