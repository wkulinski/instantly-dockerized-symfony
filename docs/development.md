## Development
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