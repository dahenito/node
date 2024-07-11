#!/bin/bash
set -xeuo pipefail

TARGET="$HOSTOS/$HOSTARCH"

##
platform_table=(
"darwin/amd64:darwin-x64.tar.gz"
"darwin/arm64:darwin-arm64.tar.gz"
"linux/amd64:linux-x64.tar.xz"
"linux/arm64:linux-arm64.tar.xz"
"windows/amd64:win-x64.zip"
"windows/arm64:win-arm64.zip"
)

function lookup() {
	local key=$1

	for kv in "${platform_table[@]}"; do
		k="${kv%%:*}"
		v="${kv##*:}"
		if [ "$k" == "$key" ]; then
			echo "$v"
			return
		fi
	done
	echo "not-supported"
}

function decompress() {
    local file=$1

    if [[ ! -f "$file" ]]; then
        echo "Not found: $file"
        return 1
    fi

    case "$file" in
        *.zip)
            unzip "$file"
            ;;
        *.tar.gz)
            tar -xzf "$file"
            ;;
        *.tar.xz)
            tar -xJf "$file"
            ;;
        *)
            echo "Unsupported file ext for $file"
            return 1
            ;;
    esac
}

##
ARC=$(lookup "$TARGET")
if [ "$ARC" == "not-supported" ]; then
	echo "Unsupported platform: $TARGET"
	exit 1
fi

NODE_URL="https://nodejs.org/dist/v$VERSION/node-v$VERSION-$ARC"
FILE="/tmp/$ARC"

#
echo "Downloading $NODE_URL..."
if ! curl -o "$FILE" "$NODE_URL"; then
  echo "Failed to download $NODE_URL"
  exit 1
fi

#
echo "Extracting $FILE..."
mkdir /stage && cd /stage
if ! decompress "$FILE"; then
  echo "Failed to extract $FILE"
  exit 1
fi
topdir=$(find /stage -maxdepth 1 -type d -name 'node-v*' -print)
mv "$topdir" /egress

# rmdir could confirm the extraction was successful
# and the layout of the extracted files is as expected
rmdir /stage

rm "$FILE"

echo "Node $VERSION setup successfully!"
##
