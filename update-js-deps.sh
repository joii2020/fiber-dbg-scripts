#!/bin/bash
cd "$(dirname "$0")/../fiber-wallet/"

rm -rf node_modules/
pnpm update @nervosnetwork/fiber-js && pnpm i -f
if [ $? -ne 0 ]; then
    echo "失败"
    exit 1
fi

