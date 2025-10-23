#!/bin/bash

xhost +local:docker

export "$@"

chmod +x docker/entrypoint.sh

docker compose -f docker/docker-compose.yml up --build

