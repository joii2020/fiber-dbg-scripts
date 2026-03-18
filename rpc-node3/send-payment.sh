#!/bin/bash

cd "$(dirname "$0")/../../"
source ./fiber-dbg-scripts/rpc/rpc-env.sh

INVOICE_ADDRESS="$1"
if [ -z "$INVOICE_ADDRESS" ]; then
  echo "Usage: $0 <invoice_address>"
  exit 1
fi

PAYLOAD=$(cat <<EOF
{
  "id": "42",
  "jsonrpc": "2.0",
  "method": "send_payment",
  "params": [{
    "invoice": "$INVOICE_ADDRESS"
  }]
}
EOF
)

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" http://localhost:$NODE3_PORT)
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo ---- ExitCode: $EXIT_CODE ----
  exit $EXIT_CODE
fi

echo "$RESPONSE"
echo ---- ExitCode: $EXIT_CODE ----
