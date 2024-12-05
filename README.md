# Dockerized SnowMirror

[![Price](https://img.shields.io/badge/price-FREE-0098f7.svg)](https://github.com/obsidiandynamics/kafdrop/blob/master/LICENSE)
[![Docker Hub](https://shields.io/docker/pulls/mikevandenberge/snowmirror)](https://hub.docker.com/u/mikevandenberge/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/mikevdberge/snowmirror-docker/blob/master/LICENSE)
[![Actions Status](https://github.com/mikevdberge/snowmirror-docker/workflows/Release%20production%20version/badge.svg)](https://github.com/mikevdberge/snowmirror-docker/actions)    

This project creates a small dockerized SnowMiror.

## Getting started

1. Create a directory for the configuration
This allows you to update `SnowMirror` by just deleting and recreating the container

```bash
mkdir $HOME/.local/share/snowmirror/
cd $HOME/.local/share/snowmirror/
```
2. Download the snowmirror.properties file in the snowmirror directory
```bash
### SnowMirror base URL ###
snowMirror.scheme = http
snowMirror.host = localhost
snowMirror.port = 9090
snowMirror.controlport = 8005
snowMirror.context =

### Installation ###
snowMirror.installation.name = SnowMirror

### SnowMirror configuration database
config.db.type = h2
config.jdbc.url = jdbc:h2:${snowMirror.dataDir}/h2/snowmirror
config.jdbc.username = sa
config.jdbc.password = sa
config.jdbc.schema =
config.jdbc.encryption = IGNORE
```
3. Download the docker-compose.yml file in the snowmirror directory
```bash
services:
    snowmirror:
      container_name: snowmirror
      image: mikevandenberge/snowmirror:latest
    ports:
      - "9090:9090"
    volumes:
    - "./snowMirror.properties:/opt/snowmirror/snowMirror.properties"
    - "./logs:/opt/snowmirror/logs"
```
4. Start the container

```bash
$ sudo docker compose up -d
```

5. Attach to a running container
```bash
docker container exec -it snowmirror /bin/bash
```
6. Open your browser and goto http://localhost:9090

