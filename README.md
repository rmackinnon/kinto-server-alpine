# kinto-server-alpine
Dockerfile to run Mozilla's Kinto in a lean Alpine Linux environment with NodeJS, NPM, and Yarn prebaked. Depends on [Michael Hart](https://github.com/mhart)'s [Alpine NodeJS]([https://github.com/mhart/alpine-node) container.

## Default Environment
```
KINTO_INI=/etc/kinto/kinto.ini
KINTO_HOST=0.0.0.0
KINTO_PORT=8888 
KINTO_STORAGE_BACKEND=memory 
KINTO_CACHE_BACKEND=memory 
KINTO_GID=10001 
KINTO_UID=10001
```

## Building
1. Clone this project into a work directory.
2. Clone [Mozilla Kinto](https://github.com/Kinto/kinto) into the same work directory
3. Copy ```kinto/kinto``` into ```kinto-server-alpine```.
4. Run ```docker-compose build --no-cache -t <some_name_here> kinto-server-alpine```

## Known Issues
1. Previously I was experiencing issues with slowing to stalling of installations via ```apk``` and socket timeout while running ```pip3```.  This was resolved eventually by specifying a network type ```host``` on the command line.  I later rolled this into the yaml compose file.
