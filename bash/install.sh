#!/usr/bin/env bash

set -e

if [ -f bash/.install-lock ]; then
    echo "Project is already created. If you are sure you want to install it again pleas remove lock file bash/.install-lock. Exiting."
    exit 0
fi

echo "Starting installation of docker environment..."

if [ ! -f .env ]; then
#    read -p "Pleas enter Symfony environment (leave empty to use default dev): " symfony_environment
#    if [ -z "$symfony_environment" ]; then
#        symfony_environment="dev"
#    fi

    read -p "Pleas enter Symfony application port (leave empty to use default 8090): " symfony_port
    if [ -z "$symfony_port" ]; then
        symfony_port="8090"
    fi

    read -p "Pleas enter Kibana application port (leave empty to use default 8091): " kibana_port
    if [ -z "$kibana_port" ]; then
        kibana_port="8091"
    fi

    while read -p 'Pleas enter your timezone: ' timezone && [[ -z "$timezone" ]] ; do
        printf "Pleas type some value.\n"
    done

    while read -p 'Pleas enter new password for Symfony application database: ' database_password && [[ -z "$database_password" ]] ; do
        printf "Pleas type some value.\n"
    done

    while read -p 'Pleas enter new username for Symfony application database: ' database_username && [[ -z "$database_username" ]] ; do
        printf "Pleas type some value.\n"
    done

    while read -p 'Pleas enter new database name for Symfony application: ' database_name && [[ -z "$database_name" ]] ; do
        printf "Pleas type some value.\n"
    done

    read -p "Pleas postgres port (leave empty to use default 5432): " database_port
    if [ -z "$database_port" ]; then
        database_port="5432"
    fi
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

    rm get-docker.sh

    # Manage as non root
    # https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user
    sudo groupadd docker
    sudo usermod -aG docker $USER

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


# Install Portainer
echo "Portainer installation..."
if [ ! "$(docker ps -a | grep portainer/portainer)" ]; then
    read -p "Pleas enter portainer port (leave empty to use default 9000): " portainer_port
    if [ -z "$portainer_port" ]; then
        portainer_port="9000"
    fi

    docker volume create portainer_data
    docker run -d -p "$portainer_port":9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

    echo "Portainer installation finished."
else
    echo "Portainer is already installed. Skipping portainer installation."
fi


# Install pgadmin4
echo "Pgadmin4 installation..."
if [ ! "$(docker ps -a | grep dpage/pgadmin4)" ]; then
    read -p "Pleas enter pgadmin4 port (leave empty to use default 5050): " pgadmin_port
    if [ -z "$pgadmin_port" ]; then
        pgadmin_port="5050"
    fi

    if [ -z "$1" ]; then
        while read -p 'Pleas enter your email: ' email && [[ -z "$email" ]] ; do
            printf "Pleas type some value.\n"
        done
    else
        email="$1"
    fi

    while read -p 'Pleas enter pgadmin4 password: ' pgadmin_password && [[ -z "$pgadmin_password" ]] ; do
        printf "Pleas type some value.\n"
    done

    docker pull dpage/pgadmin4
    docker run -p "$pgadmin_port":80 -e "PGADMIN_DEFAULT_EMAIL=$email" -e "PGADMIN_DEFAULT_PASSWORD=$pgadmin_password" -d dpage/pgadmin4

    echo "Pgadmin4 installation finished."
else
    echo "Pgadmin4 is already installed. Skipping pgadmin4 installation."
fi

# Create .env file
echo "Creating .env file..."
if [ ! -f .env ]; then
    currentdir=$(pwd)
    touch .env
    echo "SYMFONY_APP_PATH=$currentdir" >> .env
    echo "SYMFONY_APP_PORT=$symfony_port" >> .env
    echo "KIBANA_PORT=$kibana_port" >> .env
    echo "TIMEZONE=$timezone" >> .env
    echo "POSTGRES_PASSWORD=$database_password" >> .env
    echo "POSTGRES_USER=$database_username" >> .env
    echo "POSTGRES_DB=$database_name" >> .env
    echo "POSTGRES_PORT=$database_port" >> .env

    echo ".env file created."
else
    echo ".env file already exists. Skipping .env file creation."
fi

# Create local install lock
touch bash/.install-lock
#grep -q -F 'bash/.install-lock' .gitignore || echo 'bash/.install-lock' >> .gitignore

echo "Installation of docker environment completed."

sudo rm data/postgres/.gitkeep

# Start project containers
./bash/reload.sh
