#!/bin/bash

xhost +local:

export "$@"

docker compose -f docker/docker-compose.yml up --build

