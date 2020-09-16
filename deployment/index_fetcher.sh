#!/bin/bash
REPO="$1"
ASSET_PREFIX="$2"
INDEX_FILE="$3"

TEMP_DIR="$(mktemp -d)"
# Make sure we delete TEMP_DIR on exit.
trap "rm -r $TEMP_DIR" EXIT
# Abort script on failure.
set -e
# Print commands as we execute them.
set -x

cd $TEMP_DIR
/download_latest_release_assets.py --repository="$REPO" \
  --asset-prefix="$ASSET_PREFIX" \
  --output-name="index.zip"
unzip "index.zip"
mv *.idx $INDEX_FILE
