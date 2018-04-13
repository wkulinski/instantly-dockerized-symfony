#!/usr/bin/env bash

set -e

if [ -f bash/.create-lock ]; then
    echo "Project is already created. If you are sure you want to create it again pleas remove lock file bash/.create-lock. Keep in mind that re-creating project WILL lead to data loss. Exiting."
    exit 0
fi

PS3='Please choose Symfony distribution to create: '
options=("Skeleton" "Website skeleton" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Skeleton")
            distribution="symfony/skeleton"
            echo "symfony/skeleton will be installed"
            break
            ;;
        "Website skeleton")
            distribution="symfony/website-skeleton"
            echo "symfony/website-skeleton will be installed"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
if [ -z "$distribution" ]; then
    echo "Missing Symfony distribution. Exiting."
    exit 1
fi

while read -p 'Pleas enter your email: ' email && [[ -z "$email" ]] ; do
    printf "Pleas type some value.\n"
done

while read -p 'Pleas enter your full name: ' name && [[ -z "$name" ]] ; do
    printf "Pleas type some value.\n"
done

./bash/install.sh "$email"

echo "Clearing symfony folder..."
sudo chown -R $USER:$USER symfony/*
rm -Rf symfony/*
rm -Rf symfony/.gitkeep

echo "Creating Symfony project..."
# Create symfony project
COMPOSER_ALLOW_SUPERUSER=1 docker-compose exec php composer create-project "$distribution" .

# Require security checker
COMPOSER_ALLOW_SUPERUSER=1 docker-compose exec php composer require sec-checker --dev

sudo chown -R $USER:$USER symfony/*

echo "Creating git repository..."
# Initiate git repository
git init

# Set name and email
git config user.name "$name"
git config user.email "$email"

# Make creation lock (this file should be commited into repository - there is no need to create once created project)
touch bash/.create-lock

# Make initial commit
git add .
git commit -m 'Initial commit'

echo "Project creation finished successfully."
echo "For more information pleas read README.md"
