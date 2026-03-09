#!/bin/bash
cd "$(dirname "$0")/../fiber/"

if [ -n "$(git status --porcelain)" ]; then
    echo "失败: 当前仓库存在未提交或已暂存的变更，请先提交或清理后再执行。"
    exit 1
fi

# git-clean-all

../fiber-dbg-scripts/build-wasm.sh
if [ $? -ne 0 ]; then
    echo "失败: build-wasm.sh"
    exit 1
fi

cp -r fiber-js/dist/* ../fiber-wasm-dist

FIBER_GIT_LOG_ID=$(git rev-parse HEAD)

cd ../fiber-wasm-dist/
git add .
git commit -m "publish wasm dist from fiber commit ${FIBER_GIT_LOG_ID}"
git push origin main
