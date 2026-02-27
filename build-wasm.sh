cd "$(dirname "$0")/../../"

cargo build -r
if [ $? -ne 0 ]; then
    echo "失败: build -r"
    exit 1
fi

cd fiber-js/
npm i
if [ $? -ne 0 ]; then
    echo "失败: npm i"
    exit 1
fi

npm run build
if [ $? -ne 0 ]; then
    echo "失败: npm build"
    exit 1
fi
