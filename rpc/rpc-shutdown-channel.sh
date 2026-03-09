#!/bin/bash

CHANNEL_ID=${1:-}

if [ -z "$CHANNEL_ID" ]; then
  echo "Usage: $0 <channel_id> [force:false|true] [fee_rate] [rpc_url]"
  echo "Example: $0 0x1234abcd false 1000 http://localhost:8227"
  exit 1
fi

cd "$(dirname "$0")/../../"
source .vscode/dbg-tools/rpc-env.sh

PAYLOAD=$(cat <<EOF
{
  "id": "42",
  "jsonrpc": "2.0",
  "method": "shutdown_channel",
  "params": [{
    "channel_id": "$CHANNEL_ID",
    "force": false,
    "fee_rate": "0x3FC"
  }]
}
EOF
)

echo "$PAYLOAD"
echo ""

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" "http://localhost:8227")
EXIT_CODE=$?
echo "$RESPONSE"
echo ""
echo ---- ExitCode: $EXIT_CODE ----
