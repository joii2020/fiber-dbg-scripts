#!/bin/bash

cd "$(dirname "$0")/../../"
source ./fiber-dbg-scripts/rpc/rpc-env.sh

curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "connect_peer",
    "params": [
      { "address": "'$NODE3_ADDRESS'" }
    ]
  }' http://localhost:$NODE2_PORT
EXIT_CODE=$?
echo ""
echo ---- ExitCode: $EXIT_CODE ----
