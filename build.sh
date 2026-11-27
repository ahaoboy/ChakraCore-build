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

BIN="../dist/ch"
DIST="../dist"

if [[ "$(uname -s)" == Darwin ]]; then
    paths=$(otool -L "$BIN" | awk 'NR > 1 {print $1}')
else
    paths=$(ldd "$BIN" | awk '/=> \// {print $3} /^[[:space:]]*\// {print $1}')
fi

while IFS= read -r path; do
    case "$(basename "$path")" in
        libxml2*|libicuuc*|libicui18n*)
            if [[ "$(uname -s)" == Darwin && "$path" == /usr/lib/* ]]; then
                continue
            fi
            [[ -f "$path" ]] || continue
            cp -L "$path" "$DIST/"
            echo "Copied: $path"
            ;;
    esac
done <<< "$paths"

cd ..

ls -lh dist

tar -czf ./ch-${TARGET}.tar.gz -C dist .
ls -l ./ch-${TARGET}.tar.gz