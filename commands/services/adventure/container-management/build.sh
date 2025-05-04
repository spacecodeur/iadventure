#!/bin/bash

NETWORK_NAME="${APP_NAME}-docker-network"

! docker network ls | grep -q "$NETWORK_NAME" && docker network create "$NETWORK_NAME"

docker compose -f docker/adventure/compose.yml --env-file crates/services/adventure/.env up --build -d