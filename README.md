# ssh
SSH connection over Socket IO derived from discussion on [stackoverflow](http://stackoverflow.com/questions/38689707/connecting-to-remote-ssh-server-via-node-js-html5-console)

# start container
1. save local copy of docker-compose.yml and .env
2. customize .env to define ROOTURL, ALLOW=255.255.255.255/0 (ANY), DENY=0.0.0.0/32 (NONE)
3. docker-compose -f docker-compose.yml up -d
