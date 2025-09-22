#!/bin/bash

xhost +local:

eval "$@"

docker compose -f docker/docker-compose.yml up --build --build-arg $@

