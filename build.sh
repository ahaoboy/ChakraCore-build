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

for pattern in 'libicuuc*' 'libicui18n*'; do
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS
        paths=$(find /usr/lib /usr/local/lib /opt/homebrew/lib \
            -name "$pattern" -type f 2>/dev/null || true)
    else
        # Linux
        paths=$(ldconfig -p 2>/dev/null |
            awk -v pattern="$pattern" 'index($1, pattern) == 1 { print $NF }')
    fi

    if [[ -z "$paths" ]]; then
        echo "Missing: $pattern"
        exit 1
    fi

    while IFS= read -r path; do
        [[ -f "$path" ]] || continue
        cp -L "$path" ../dist/
        echo "Copied: $path -> ../dist/"
    done <<< "$paths"
done

cd ..

ls -lh dist

tar -czf ./ch-${TARGET}.tar.gz -C dist .
ls -l ./ch-${TARGET}.tar.gz