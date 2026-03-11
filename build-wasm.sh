#!/bin/bash
cd "$(dirname "$0")/../fiber/"

cargo build -r --all
if [ $? -ne 0 ]; then
    echo "失败: build -r"
    exit 1
fi

cd crates/fiber-wasm
npm i && npm run build
if [ $? -ne 0 ]; then
    echo "失败: npm i"
    exit 1
fi

cd ../fiber-wasm-db-worker
npm i && npm run build
if [ $? -ne 0 ]; then
    echo "失败: npm i"
    exit 1
fi

cd fiber-js/
npm i && npm run build
if [ $? -ne 0 ]; then
    echo "失败"
    exit 1
fi
