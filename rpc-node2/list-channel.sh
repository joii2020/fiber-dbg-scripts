#!/bin/bash

cd "$(dirname "$0")/../../"
source ./fiber-dbg-scripts/rpc/rpc-env.sh

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "list_channels",
    "params": [{
      "pubkey": "'$NODE3_PUBKEY'"
    }]
  }' http://localhost:8237)
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo ---- ExitCode: $EXIT_CODE ----
  exit $EXIT_CODE
fi

echo "$RESPONSE" | node -e '
const fs = require("fs");
const raw = fs.readFileSync(0, "utf8");
let data;
try {
  data = JSON.parse(raw);
} catch (err) {
  console.error("Invalid JSON response");
  process.exit(1);
}

const channels = data?.result?.channels;
if (!Array.isArray(channels)) {
  console.error("Missing result.channels in response");
  process.exit(1);
}

for (const channel of channels) {
  const channelId = channel?.channel_id ?? "";
  const stateName = channel?.state?.state_name ?? "";
  if (channelId && stateName) {
    console.log(`${channelId} ${stateName}`);
  }
}
'
EXIT_CODE=$?
echo ---- ExitCode: $EXIT_CODE ----
