#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

NODE1_PATH="$PROJECT_ROOT/test-nodes/node1"
NODE3_PATH="$PROJECT_ROOT/test-nodes/node3"

NODE1_PEERID=QmPs5guif66ptX3ZhvCkq2d71Du9bLtyVRq2aKJ2fibPyw
NODE3_PEERID=QmcMXciBEWiJjCnNCmNEy4sCdKASFWNnmBvU4BZHRd4sGT