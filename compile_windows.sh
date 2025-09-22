#!/bin/bash

xhost +local:

docker compose -f docker/docker-compose.yml up --build "$@"

