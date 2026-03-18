#!/bin/bash

__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__PROJECT_ROOT="$(dirname "$(dirname "$__SCRIPT_DIR")")"

NODE1_PATH="$__PROJECT_ROOT/test-nodes/node1"
NODE2_PATH="$__PROJECT_ROOT/test-nodes/node2"
NODE3_PATH="$__PROJECT_ROOT/test-nodes/node3"

NODE1_PORT=8227
NODE2_PORT=8237
NODE3_PORT=8247

# Fiber p2p listening ports in test-nodes configs.
NODE1_FIBER_PORT=8228
NODE2_FIBER_PORT=8238
NODE3_FIBER_PORT=8248

is_local_port_open() {
  local port="$1"
  nc -z localhost "$port" >/dev/null 2>&1
}

get_node_info_response() {
  local port="$1"

  if ! is_local_port_open "$port"; then
    echo ""
    return 0
  fi

  local response
  response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{
      "id": "42",
      "jsonrpc": "2.0",
      "method": "node_info",
      "params": []
    }' "http://localhost:${port}")

  if [ $? -ne 0 ] || [ -z "$response" ]; then
    echo ""
    return 0
  fi

  echo "$response"
}

get_node_pubkey() {
  local port="$1"
  local response

  response="$(get_node_info_response "$port")"
  if [ -z "$response" ]; then
    echo ""
    return 0
  fi

  echo "$response" | grep -o '"pubkey":"[^"]*"' | head -n 1 | cut -d '"' -f 4
}

get_node_peer_id() {
  local port="$1"
  local response

  response="$(get_node_info_response "$port")"
  if [ -z "$response" ]; then
    echo ""
    return 0
  fi

  # First try extracting /p2p/<peer_id> from node_info.addresses.
  local peer_id
  peer_id="$(echo "$response" | grep -o '/p2p/[^\"/[:space:]]*' | head -n 1 | cut -d '/' -f 3)"
  if [ -n "$peer_id" ]; then
    echo "$peer_id"
    return 0
  fi

  # Fallback: derive PeerId from pubkey (tentacle-secio):
  # PeerId = base58(0x12 || 0x20 || sha256(pubkey_bytes)).
  local pubkey
  pubkey="$(echo "$response" | grep -o '"pubkey":"[^"]*"' | head -n 1 | cut -d '"' -f 4)"
  if [ -z "$pubkey" ]; then
    echo ""
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$pubkey" <<'PY'
import hashlib
import sys

pub = sys.argv[1].strip().lower()
if pub.startswith("0x"):
    pub = pub[2:]

try:
    raw = bytes.fromhex(pub)
except ValueError:
    print("")
    raise SystemExit(0)

digest = hashlib.sha256(raw).digest()
data = bytes([0x12, 0x20]) + digest

alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
n = int.from_bytes(data, "big")
out = []
while n > 0:
    n, rem = divmod(n, 58)
    out.append(alphabet[rem])
out = "".join(reversed(out)) if out else "1"
leading = 0
for b in data:
    if b == 0:
        leading += 1
    else:
        break
print(("1" * leading) + out)
PY
    return 0
  fi

  echo ""
}

build_node_address() {
  local fiber_port="$1"
  local peer_id="$2"

  if [ -z "$peer_id" ]; then
    echo ""
    return 0
  fi

  echo "/ip4/127.0.0.1/tcp/${fiber_port}/ws/p2p/${peer_id}"
}

NODE1_PUBKEY="$(get_node_pubkey "$NODE1_PORT")"
NODE2_PUBKEY="$(get_node_pubkey "$NODE2_PORT")"
NODE3_PUBKEY="$(get_node_pubkey "$NODE3_PORT")"

NODE1_PEERID="$(get_node_peer_id "$NODE1_PORT")"
NODE2_PEERID="$(get_node_peer_id "$NODE2_PORT")"
NODE3_PEERID="$(get_node_peer_id "$NODE3_PORT")"

NODE1_ADDRESS="$(build_node_address "$NODE1_FIBER_PORT" "$NODE1_PEERID")"
NODE2_ADDRESS="$(build_node_address "$NODE2_FIBER_PORT" "$NODE2_PEERID")"
NODE3_ADDRESS="$(build_node_address "$NODE3_FIBER_PORT" "$NODE3_PEERID")"
