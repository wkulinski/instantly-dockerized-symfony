# Instantly Dockerized Symfony 4 Project

## What's included
With only few commands you instantly receive complete Symfony and Docker
environment with:
- Symfony 4 ready to work:
  - You can choose to use skeleton or website-skeleton
- Dockerized environment with: 
  - Nginx
  - php7
  - Postgres
- Helpful tools: 
  - Portainer - for docker management
  - PgAdmin4 - for database management
  - Kibana - for logs management
- Local Docker registry
  - Including registry and registry UI    
- Helpful developer commands
  - To make work faster and simpler (read about **ins** command below) 

## How to access
After successful installation of all components you receive access to a few applications. 
Assuming you haven't changed default ports during installation (of course you can!) you can find them here:
- Your Symfony 4 application: [http://localhost:8090](http://localhost:8090)
- Portainer: [http://localhost:9000](http://localhost:9000)
- PgAdmin: [http://localhost:5050](http://localhost:5050)
- Kibana: [http://localhost:8091](http://localhost:8091)
- Docker registry UI: [http://localhost:5001](http://localhost:5001)

And also:
- Postgres: [postgres_container_gateway|localhost]:5432
- Docker registry: **https**://[docker_registry_container_gateway|localhost]:5000

## How to use
Pleas check project documentation

* [Creation and installation](docs/start.md) (Start new project or participate in existing one)
* [Utilities](docs/utility.md) (Pgadmin 4, Portainer, Docker registry and Docker registry UI)
* [Development](docs/development.md) (Make your work easier)
* [Certificates](docs/certificate.md) (Generate self signed certificates)
* [Builds](docs/build.md) (Make builds and push to registry)
* [Deployment](docs/deploy.md) (Get your project live!)
* [Customisation](docs/customisation.md) (Adjust this tool to your needs)
* [Frequent problems](docs/problems.md) (Before you waste your time on searching - just look here)
