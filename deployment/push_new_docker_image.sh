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
cp ../docker/status_updater.sh "$TEMP_DIR/"
cp -r ../docker/status_templates "$TEMP_DIR/"
cp -r ../docs "$TEMP_DIR/"
cp ../download_latest_release_assets.py "$TEMP_DIR/"
cd "$TEMP_DIR"

# Generate static pages for serving.
cd docs
REPOSITORY=$INDEX_REPO j2 ../status_templates/contact > contact.html

export GRIPHOME="$(pwd)"
export GRIPURL="$(pwd)"
echo "CACHE_DIRECTORY = '$(pwd)/asset'" > settings.py
for f in *.md; do
  BASE_NAME="${f%.*}"
  OUT_FILE="${BASE_NAME}.html"
  grip --export - $OUT_FILE --no-inline < $f
  # Replace links to current directory with root.
  sed -i "s@$(pwd)@@g" $OUT_FILE
  # Replace links to current directory with root.
  sed -i "s@<title>.*</title>@<title>${BASE_NAME} - ${PROJECT_ID}</title>@g" \
    $OUT_FILE
  # Insert the footer section for the navbar.
  sed -i "\@</article>@e cat contact.html" $OUT_FILE
done

for f in asset/*.css; do
  sed -i "\@</head>@i <link rel=\"stylesheet\" href=\"/$f\" />" ../status_templates/header
done

rm -f *.md settings.py footer.html
chmod -R a+rx *
cd ..

# First download and extract remote index server.
./download_latest_release_assets.py \
  --repository="clangd/clangd" \
  --asset-prefix="$SERVER_ASSET_PREFIX" \
  --output-name="$OUTPUT_NAME"
# Extract clangd-index-server and monitor.
unzip -j "$OUTPUT_NAME" "*/bin/clangd-index-server*"
chmod +x clangd-index-server clangd-index-server-monitor

# Build the image, tag it for GCR and push.
docker build --build-arg REPOSITORY="$INDEX_REPO" \
  --build-arg INDEX_ASSET_PORT_PAIRS="$INDEX_ASSET_PORT_PAIRS" \
  --build-arg INDEXER_PROJECT_ROOT="$INDEXER_PROJECT_ROOT" \
  --build-arg PROJECT_NAME="$PROJECT_ID" \
  -t "$IMAGE_IN_GCR" .
gcloud auth configure-docker
docker push "$IMAGE_IN_GCR"
