#!/bin/bash

cd "$(dirname "$0")/../fiber/"
source ./../fiber-dbg-scripts/rpc/rpc-env.sh

: > .vscode/logs/log-node3.log
export FIBER_SECRET_KEY_PASSWORD='x'
export RUST_LOG=info
./target/release/fnn -c $NODE3_PATH/config.yml -d $NODE3_PATH
