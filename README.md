# Instantly Dockerized Symfony Project

## What's included
With only few commands you instantly receive complete Symfony and Docker
environment with:
- Symfony 4 ready to work:
  - you can choose to use skeleton or website-skeleton
- Dockerized environment with: 
  - nginx
  - php7
  - postgres
- Helpful tools: 
  - Portainer - for docker management
  - PgAdmin4 - for database management
  - Kibana - for logs management

## How to access
After successful installation you receive access to a few applications. 
Assuming you haven't changed default ports during installation (of course you can!) you can find them here:
- Your Symfony application: http://localhost:8090
- Portainer: http://localhost:9000
- PgAdmin: http://localhost:5050
- Kibana: http://localhost:8091

## Creation and installation
### To create new project
##### Clone this repository

```
git clone https://github.com/wkulinski/instantly-dockerized-symfony.git
```

##### Export path (optionally)
This will allow you to use command **ins** without ./  
**ins** command is like **instant**... You know... Like instant project... Oh never mind ;)
```
./ins export
```

##### Create project
```
ins create
```
Just follow installation instructions.

That's IT! You have brand new fully working Symfony project on 
docker with all tools helful in developement.

###### What is done with create command?
Create command will:
- install docker (IF it's not installed yet)
- install docker-compose (IF it's not installed yet)
- install portainer (IF it's not installed yet)
- install pgadmin4 (IF it's not installed yet)
- create and fill docker .env file (IF you haven't done it manually)
- compose postgres, nginx and php, and kibana images and create containers
- store postgres data inside data/postgres/ folder (so you will not loose it by removing container. Keep in mind that this folder MUST be empty otherwise data won't be created.)
- create new Symfony project inside symfony/ folder (keep in mind that this folder MUST be empty otherwise Symfony project won't be created.)
- init new git repository and make initial commit

### To participate in existing project
Lets assume you created you own new project locally, made some work, 
pushed it on your remote repository, and want your colleagues 
to participate. Say no more!

##### Clone your own repository

```
git clone [path-to-your-repo]
```

##### Export path (optionally)
This will allow you to use command **ins** without ./
```
./ins export
```

##### Install project
```
ins install
```

Keep in mind that you are installing existing project NOT creating new.

And that's it!

###### What is done with install command?
Create command will:
- install docker (IF it's not installed yet)
- install docker-compose (IF it's not installed yet)
- install portainer (IF it's not installed yet)
- install pgadmin4 (IF it's not installed yet)
- create and fill docker .env file (IF you haven't done it manually)
- compose postgres, nginx and php, and kibana images and create containers
- store postgres data inside data/postgres/ folder (so you will not loose it by removing container. Keep in mind that this folder MUST be empty otherwise data won't be created.)

## Developement
This project contains bunch of helpful commands and tools to make development 
and deployment easier.

#### Use symfony console
```
ins console [command]
```
or use one of aliases
```
ins symfony [command]
ins sf [command]
```

This command is shortcut for
```
docker-compose exec php php bin/console "${@:2}"
```

#### Use composer
```
ins composer [command]
```
or use one of aliases
```
ins comp [command]
ins co [command]
```

This command is shortcut for
```
docker-compose exec php composer "${@:2}"
```

#### Access application/php container shell
```
ins app
```
or use alias
```
ins php
```

This command is shortcut for
```
docker-compose exec php sh
```

#### Access nginx container shell
```
ins nginx
```
or use alias
```
ins server
```
This command is shortcut for
```
docker-compose exec nginx sh
```


#### Access postgres container shell
```
ins postgres
```
or use alias
```
ins db
```
This command is shortcut for
```
docker-compose exec db sh
```

#### Build your project on rc or prod server
Use command without any flag to build from **origin/develop** branch (for example on test or rc sever)
```
ins build
```
Use command with **--prod** flag to build from **origin/master** branch (for example prod sever)
```
ins build --prod
```


#### Stop docker containers
```
ins stop
```

#### Reload docker containers
```
ins reload
```

#### Others
Calling **ins** with any argument(s) other than shown above is equal to calling
```
docker-compose exec [arguments]
```

