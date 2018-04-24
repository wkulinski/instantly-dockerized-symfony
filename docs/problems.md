## Frequent problems
##### Can't configure pgadmin4 to connect my localhost database
Pleas use **Gateway** instead of **ip** of your **postgres** container as host 
in pgadmin4 connection settings. 
You can check gateway using Portainer. Just go to postgres container 
details and go to "Connected networks" area on bottom of page.