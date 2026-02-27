#!/bin/bash

cd "$(dirname "$0")/../../"
source .vscode/dbg-tools/rpc-env.sh

killall fnn
cargo build -r
if [ $? -ne 0 ]; then
    echo "失败: cargo build -r"
    exit 1
fi

: > .vscode/logs/log-node3.log
export FIBER_SECRET_KEY_PASSWORD='x'
export RUST_LOG=info
nohup ./target/release/fnn -c $NODE3_PATH/config.yml -d $NODE3_PATH > .vscode/logs/log-node3.log  2>&1 &

: > .vscode/logs/log-dbg.log
nohup ./target/release/fnn -c $NODE1_PATH/config.yml -d $NODE1_PATH > .vscode/logs/log-dbg.log  2>&1 &

while ! grep -q "listening tentacle on" .vscode/logs/log-node3.log; do
    sleep 0.2
done
echo "Node3 ready"

while ! grep -q "listening tentacle on" .vscode/logs/log-dbg.log; do
    sleep 0.2
done
echo "NodeDbg ready"

sleep 2

.vscode/dbg-tools/rpc-connect.sh
