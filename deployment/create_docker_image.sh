#!/bin/bash

INDEX_REPO="clangd/llvm-remote-index"
IMAGE_NAME="llvm-remote-index-server"
INDEX_ASSET_PREFIX="llvm-index"
SERVER_ASSET_PREFIX="clangd-indexing-tools-linux"
OUTPUT_NAME="$SERVER_ASSET_PREFIX.zip"
INDEXER_PROJECT_ROOT="/home/runner/work/llvm-remote-index/llvm-remote-index/llvm-project/"

TEMP_DIR="$(mktemp -d)"
# Make sure we delete TEMP_DIR on exit.
trap "rm -r $TEMP_DIR" EXIT

# Abort script on failure.
set -e
# Print commands as we execute them.
set -x

cp deployment/Dockerfile "$TEMP_DIR/"
cp deployment/index_fetcher.sh "$TEMP_DIR/"
cp deployment/entry_point.sh "$TEMP_DIR/"
cp download_latest_release_assets.py "$TEMP_DIR/"

cd "$TEMP_DIR"

# First download and extract remote index server.
./download_latest_release_assets.py \
  --repository="clangd/clangd" \
  --asset-prefix="$SERVER_ASSET_PREFIX" \
  --output-name="$OUTPUT_NAME"
# Only extract clangd-index-server.
unzip -j "$OUTPUT_NAME" "*/bin/clangd-index-server"
chmod +x clangd-index-server

docker build --build-arg REPOSITORY="$INDEX_REPO" \
  --build-arg INDEX_ASSET_PREFIX="$INDEX_ASSET_PREFIX" \
  --build-arg INDEXER_PROJECT_ROOT="$INDEXER_PROJECT_ROOT" \
  -t "$IMAGE_NAME" .
