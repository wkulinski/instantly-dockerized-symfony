#!/usr/bin/env bash

set -e

prod=false
version=""
while getopts 'pv:' flag; do
    case "${flag}" in
        p) prod=true ;;
        v) version="${OPTARG}" ;;
    esac
done

#docker stack deploy live --compose-file=docker-compose.live.yml

docker deploy build/artifact
