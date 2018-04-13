#!/usr/bin/env bash

echo "Post build hook start."

COMPOSER_ALLOW_SUPERUSER=1 docker-compose exec php composer install --no-interaction --classmap-authoritative --optimize-autoloader

docker-compose exec php php bin/console doctrine:database:create --if-not-exists
docker-compose exec php php bin/console doctrine:migrations:migrate --no-interaction

rm ./var/jwt/*
openssl genrsa -out ./var/jwt/private.pem -passout pass:"I34DGPBV5K1I6z6krvWx" -aes256 4096 -noout
openssl rsa -pubout -in ./var/jwt/private.pem -passin pass:"I34DGPBV5K1I6z6krvWx" -out ./var/jwt/public.pem

chown -R www-data:www-data .

# Disable maintenance mode
docker-compose exec php php bin/console app:maintenance --disable

echo "Post build hook finish."
