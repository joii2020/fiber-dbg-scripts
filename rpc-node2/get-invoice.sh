curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42",
    "jsonrpc": "2.0",
    "method": "get_invoice",
    "params": [{
      "payment_hash": "0x03e6ba520433fbb62be5c835a5cf9d1fb552899eb2d178b9b9eaa1de92ac4ff629"
    }]
  }' http://localhost:8247