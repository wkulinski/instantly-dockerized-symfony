# Instantly Dockerized Utilities

## What's included
With only few commands you instantly receive complete Symfony and Docker
environment with:
- Docker (will be installed automatically if not installed yet)
- Docker Compose (will be installed automatically if not installed yet)
- Symfony 4 ready to work:
  - You can choose to use skeleton or website-skeleton
- Dockerized environment with: 
  - Nginx
  - php7
  - Postgres
- Helpful tools: 
  - Kibana - for logs management
- Helpful developer commands
  - To make work faster and simpler (read about **ins** command below) 

## How to access
After successful installation of all components you receive access to a few applications. 
Assuming you haven't changed default ports during installation (of course you can!) you can find them here:
- Your Symfony 4 application: [http://localhost:8090](http://localhost:8090)
- Kibana: [http://localhost:8091](http://localhost:8091)

And also:
- Postgres: [postgres_container_gateway|localhost]:5432

## How to use
Pleas check project documentation

* [Creation and installation](docs/start.md) (Start new project or participate in existing one)
* [Development](docs/development.md) (Make your work easier)
* [Builds](docs/build.md) (Make builds and push to registry)
* [Deployment](docs/deploy.md) (Get your project live!)
* [Customisation](docs/customisation.md) (Adjust this tool to your needs)
* [Docker management](docs/management.md) (Easily manage project docker containers and images)
* [Frequent problems](docs/problems.md) (Before you waste your time on searching - just look here)

## You might also want
If you want make your life easier, and I bet you do, pleas check additional 
repository with helpful dockerized utilities like Portainer, PgAdmin or Docker registry:  
[Instantly Dockerized Utilities](https://github.com/wkulinski/instantly-dockerized-utilities)

