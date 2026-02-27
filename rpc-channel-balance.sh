#!/bin/bash

INCLUDE_CLOSED=${2:-false}
cd "$(dirname "$0")/../../"
source .vscode/dbg-tools/rpc-env.sh

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "list_channels",
    "params": [{
      "peer_id": "'$NODE3_PEERID'",
      "include_closed": '$INCLUDE_CLOSED'
    }]
  }' http://localhost:8227)
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
} catch {
  console.error("Invalid JSON response");
  process.exit(1);
}

if (data?.error) {
  console.error(JSON.stringify(data.error, null, 2));
  process.exit(1);
}

const channels = data?.result?.channels;
if (!Array.isArray(channels)) {
  console.error("Missing result.channels in response");
  process.exit(1);
}

if (channels.length === 0) {
  console.log("No channels found");
  process.exit(0);
}

for (const channel of channels) {
  const channelId = channel?.channel_id ?? "";
  const stateName = channel?.state?.state_name ?? "";
  const localBalance = channel?.local_balance ?? "";
  const remoteBalance = channel?.remote_balance ?? "";
  const offeredTlcBalance = channel?.offered_tlc_balance ?? "";
  const receivedTlcBalance = channel?.received_tlc_balance ?? "";

  console.log(`channel_id: ${channelId}`);
  console.log(`state: ${stateName}`);
  console.log(`local_balance: ${localBalance}`);
  console.log(`remote_balance: ${remoteBalance}`);
  console.log(`offered_tlc_balance: ${offeredTlcBalance}`);
  console.log(`received_tlc_balance: ${receivedTlcBalance}`);
  console.log("---");
}
'
EXIT_CODE=$?
echo ---- ExitCode: $EXIT_CODE ----


#!/bin/bash

INCLUDE_CLOSED=${2:-false}
cd "$(dirname "$0")/../../"

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "list_channels",
    "params": [{
      "peer_id": "'$NODE3_PEERID'",
      "include_closed": '$INCLUDE_CLOSED'
    }]
  }' http://localhost:8247)
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
} catch {
  console.error("Invalid JSON response");
  process.exit(1);
}

if (data?.error) {
  console.error(JSON.stringify(data.error, null, 2));
  process.exit(1);
}

const channels = data?.result?.channels;
if (!Array.isArray(channels)) {
  console.error("Missing result.channels in response");
  process.exit(1);
}

if (channels.length === 0) {
  console.log("No channels found");
  process.exit(0);
}

for (const channel of channels) {
  const channelId = channel?.channel_id ?? "";
  const stateName = channel?.state?.state_name ?? "";
  const localBalance = channel?.local_balance ?? "";
  const remoteBalance = channel?.remote_balance ?? "";
  const offeredTlcBalance = channel?.offered_tlc_balance ?? "";
  const receivedTlcBalance = channel?.received_tlc_balance ?? "";

  console.log(`channel_id: ${channelId}`);
  console.log(`state: ${stateName}`);
  console.log(`local_balance: ${localBalance}`);
  console.log(`remote_balance: ${remoteBalance}`);
  console.log(`offered_tlc_balance: ${offeredTlcBalance}`);
  console.log(`received_tlc_balance: ${receivedTlcBalance}`);
  console.log("---");
}
'
EXIT_CODE=$?
echo ---- ExitCode: $EXIT_CODE ----
