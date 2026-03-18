curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "list_channels",
    "params": [{
      "pubkey": "'$NODE3_PUBKEY'"
    }]
  }' http://localhost:8247