#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <BASTION_NAME> <RESOURCE_GROUP> <TARGET_RESOURCE_ID>"
  exit 1
fi

BASTION_NAME="$1"
RESOURCE_GROUP="$2"
TARGET_RESOURCE_ID="$3"
RESOURCE_PORT=22
LOCAL_PORT=2222
TIMEOUT=60
INTERVAL=2
ELAPSED=0

az extension add --name bastion

# 'nohup' starts the tunnel in the background.
nohup az network bastion tunnel \
  --name "$BASTION_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --target-resource-id "$TARGET_RESOURCE_ID" \
  --resource-port "$RESOURCE_PORT" \
  --port "$LOCAL_PORT" > tunnel.log 2>&1 &

echo "Starting Azure Bastion Tunnel..."

# Wait for the tunnel's port to become available.

until nc -z localhost "$LOCAL_PORT" || [ $ELAPSED -ge $TIMEOUT ]; do
  echo "Waiting for tunnel on port $LOCAL_PORT... ($ELAPSED seconds elapsed)"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
  echo "Error: Tunnel did not become available within $TIMEOUT seconds." >&2
  exit 1
fi

echo "Tunnel is up and running on port $LOCAL_PORT."