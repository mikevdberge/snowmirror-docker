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
$ mkdir $HOME/.local/share/snowmirror/conf
```


2. Start a container

```bash
$ sudo docker run -d --name snowmirror --restart=always -p 9090:9090 \
      -v $HOME/.local/share/snowmirror:/opt/snowmirror/conf \
      -e 'MODE=native' mikevandenberge/snowmirror
```
