# Dockerized SnowMirror

This project creates a small dockerized SnowMiror.

[Docker Images:  
    ![Docker Hub](https://shields.io/docker/pulls/mikevandenberge/snowmirror)](https://hub.docker.com/u/mikevandenberge/)
    
[License:  
    [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/mikevdberge/snowmirror-docker/blob/master/LICENSE)
    
[![Actions Status](https://github.com/mikevdberge/snowmirror-docker/workflows/Release%20production%20version/badge.svg)](https://github.com/mikevdberge/snowmirror-docker/actions)    

## Getting started

1. Create a directory for the configuration
This allows you to update `SnowMirror` by just deleting and recreating the container

```bash
mkdir $HOME/.local/share/snowmirror/conf
```

2. Download the docker-compose.yml file
```bash
services:
    snowmirror:
      container_name: snowmirror
      image: mikevandenberge/snowmirror:latest
    ports:
      - "80:80"
    volumes:
    - "./snowMirror.properties:/opt/snowmirror/snowMirror.properties"
    - "./logs:/opt/snowmirror/logs"
```
3. Start the container

```bash
$ sudo docker compose up -d
```

4. Attach to a running container
```bash
docker container exec -it snowmirror /bin/bash
```
