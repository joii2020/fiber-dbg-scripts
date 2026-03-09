#!/bin/bash

cd "$(dirname "$0")/../../"
source .vscode/dbg-tools/rpc-env.sh

curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "connect_peer",
    "params": [
      {"address": "/ip4/127.0.0.1/tcp/8248/p2p/'$NODE3_PEERID'"}
    ]
  }' http://localhost:8227
EXIT_CODE=$?
echo ""
echo ---- ExitCode: $EXIT_CODE ----
