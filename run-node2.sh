#!/bin/bash

cd "$(dirname "$0")/../fiber/"
source ./../fiber-dbg-scripts/rpc/rpc-env.sh

: > fiber-dbg-scripts/logs/log-node2.log
export FIBER_SECRET_KEY_PASSWORD='x'
export RUST_LOG=info
./target/release/fnn -c $NODE2_PATH/config.yml -d $NODE2_PATH
