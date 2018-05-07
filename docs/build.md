## Build your project on rc or prod server

Pleas note that on first command run you will be asked for your private Docker registry path 
(than it will be saved in .env file). 
If you don't have private registry you can easily create one with 
[Instantly Dockerized Utilities](https://github.com/wkulinski/instantly-dockerized-utilities).

#### Dev
Use command without any flag to build from **origin/develop** branch (for example 
on test or rc sever)
```
ins build
```

Note that version of created images will be tagged with "dev" flag.

#### Prod
Use command with **-p** flag to build from **origin/master** branch (for example 
prod sever)
```
ins build -p
```

Note that you can use **-v** flag to pass version number to tag your images
or you will be asked to pass version number in prompt.

#### Disable fetch and reset do develop/master branch
You can disable fetching and resetting repository to those branches 
and use current code "as it is" by using **-f** flag.
