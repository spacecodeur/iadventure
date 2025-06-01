#!/bin/bash

NETWORK_NAME="${APP_NAME}-docker-network"

! docker network ls | grep -q "$NETWORK_NAME" && docker network create "$NETWORK_NAME"

docker compose -f docker/gamemaster/compose.yml --env-file crates/services/gamemaster/.env up --build -d