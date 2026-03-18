#!/bin/bash

cd "$(dirname "$0")/../../"
source ./fiber-dbg-scripts/rpc/rpc-env.sh

# 1000ckb
FUNDING_AMOUNT=0x174876E800

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "open_channel",
    "params": [{
      "pubkey": "'$NODE3_PUBKEY'",
      "funding_amount": "'$FUNDING_AMOUNT'",
      "public": true
    }]
  }' http://localhost:$NODE2_PORT)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo ---- ExitCode: $EXIT_CODE ----
  exit $EXIT_CODE
fi

echo "$RESPONSE"
