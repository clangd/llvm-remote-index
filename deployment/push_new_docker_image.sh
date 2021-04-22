#!/bin/bash
source args.sh

SERVER_ASSET_PREFIX="clangd_indexing_tools-linux"
OUTPUT_NAME="$SERVER_ASSET_PREFIX.zip"

TEMP_DIR="$(mktemp -d)"
# Make sure we delete TEMP_DIR on exit.
trap "rm -r $TEMP_DIR" EXIT

# Copy all the necessary files for docker image into a temp directory and move
# into it.
cp ../docker/Dockerfile "$TEMP_DIR/"
cp ../docker/index_fetcher.sh "$TEMP_DIR/"
cp ../docker/entry_point.sh "$TEMP_DIR/"
cp ../download_latest_release_assets.py "$TEMP_DIR/"
cd "$TEMP_DIR"

# First download and extract remote index server.
./download_latest_release_assets.py \
  --repository="clangd/clangd" \
  --asset-prefix="$SERVER_ASSET_PREFIX" \
  --output-name="$OUTPUT_NAME"
# Only extract clangd-index-server.
unzip -j "$OUTPUT_NAME" "*/bin/clangd-index-server"
chmod +x clangd-index-server

# Build the image, tag it for GCR and push.
docker build --build-arg REPOSITORY="$INDEX_REPO" \
  --build-arg INDEX_ASSET_PREFIX="$INDEX_ASSET_PREFIX" \
  --build-arg INDEXER_PROJECT_ROOT="$INDEXER_PROJECT_ROOT" \
  -t "$IMAGE_IN_GCR" .
gcloud auth configure-docker
docker push "$IMAGE_IN_GCR"
