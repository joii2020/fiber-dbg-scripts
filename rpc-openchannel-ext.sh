#!/bin/bash

cd "$(dirname "$0")/../../"
source .vscode/dbg-tools/rpc-env.sh

FUNDING_AMOUNT=0x174876E800
CKB_PRIV_KEY=0x7ab050ecf4375b1e2faa3c7331c3071582830a07d14c36990b4d3893bddec399

LOCK_SCRIPT_JSON=$(node .vscode/dbg-tools/utils/derive-lock-script.mjs "$CKB_PRIV_KEY")

echo ---- open_channel_with_external_funding ----
PAYLOAD=$(cat <<EOF
{
  "id": "42",
  "jsonrpc": "2.0",
  "method": "open_channel_with_external_funding",
  "params": [{
    "peer_id": "$NODE3_PEERID",
    "funding_amount": "$FUNDING_AMOUNT",
    "public": true,
    "shutdown_script": $LOCK_SCRIPT_JSON,
    "funding_lock_script": $LOCK_SCRIPT_JSON
  }]
}
EOF
)

echo $PAYLOAD
echo ""
CURL_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" http://localhost:8227)


EXIT_CODE=$?
echo "$CURL_RESPONSE"
echo ""
echo ---- ExitCode: $EXIT_CODE ----
echo --------------------------

if [ $EXIT_CODE -ne 0 ]; then
  exit $EXIT_CODE
fi

echo ---- Sign TX Local ----
SIGNED_SUBMIT_PARAMS=$(node .vscode/dbg-tools/utils/sign-openchannel-response.mjs "$CURL_RESPONSE" "$CKB_PRIV_KEY")
EXIT_CODE=$?
echo "$SIGNED_SUBMIT_PARAMS"
echo ""
echo ---- Sign ExitCode: $EXIT_CODE ----

if [ $EXIT_CODE -ne 0 ]; then
  exit $EXIT_CODE
fi


echo ---- Check By ckb-cli ----
TMP_TX_FILE=$(mktemp)
trap 'rm -f "$TMP_TX_FILE"' EXIT

node .vscode/dbg-tools/utils/extract-signed-funding-tx.mjs "$SIGNED_SUBMIT_PARAMS" > "$TMP_TX_FILE"
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  exit $EXIT_CODE
fi

CKB_CHECK_OUTPUT=$(ckb-cli rpc test_tx_pool_accept \
  --tx-file "$TMP_TX_FILE" \
  --output-format json \
  --no-color 2>&1)
EXIT_CODE=$?
echo "$CKB_CHECK_OUTPUT"
echo ""
echo ---- ckb-cli check ExitCode: $EXIT_CODE ----
if [ $EXIT_CODE -ne 0 ]; then
  exit $EXIT_CODE
fi

node .vscode/dbg-tools/utils/check-tx-pool-accept-output.mjs "$CKB_CHECK_OUTPUT"
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  exit $EXIT_CODE
fi


echo ---- submit_signed_funding_tx ----
PAYLOAD=$(cat <<EOF
{
  "id": "42",
  "jsonrpc": "2.0",
  "method": "submit_signed_funding_tx",
  "params": [
    $SIGNED_SUBMIT_PARAMS
  ]
}
EOF
)
echo $PAYLOAD
echo ""
SUBMIT_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" http://localhost:8227)
EXIT_CODE=$?
echo "$SUBMIT_RESPONSE"
echo ""
echo ---- ExitCode: $EXIT_CODE ----


for _ in {1..10}; do
  echo ---- list channels ----
  .vscode/dbg-tools/rpc-list-channel.sh
  sleep 0.2
done
