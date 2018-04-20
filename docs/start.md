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

That's IT! You have brand new fully working Symfony 4 project on 
docker with all tools helpful in development.

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
