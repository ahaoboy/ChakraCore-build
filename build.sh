#!/bin/bash

if [ $# -ne 1 ]; then
    echo "not found target"
    exit 1
fi

TARGET=$1

git clone https://github.com/Microsoft/ChakraCore ch --depth=1
cd ch

./build.sh

mkdir ../dist

cp ./out/Release/ch ../dist/ch
cp -r ./out/Release/libChakraCore* ../dist

cd ..

ls -lh dist

tar -czf ./ch-${TARGET}.tar.gz -C dist .
ls -l ./ch-${TARGET}.tar.gz