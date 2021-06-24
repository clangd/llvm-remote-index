#!/bin/bash
# Helper to start a server, by fetching the relevant index once, and restart it
# if it crashes.

INDEX_FETCHER_CMD=$1
INDEX_FILE=$2
INDEXER_PROJECT_ROOT=$3
PORT=$4
LOG_PREFIX=$5

# Fetch index once.
$INDEX_FETCHER_CMD
# Start the server.
until /clangd-index-server $INDEX_FILE $INDEXER_PROJECT_ROOT -log-public \
  -server-address="0.0.0.0:${PORT}" -log-prefix=$LOG_PREFIX
do
  echo "Restarting index-server ${LOG_PREFIX}. Exited with code $?." >&2
  sleep 1
done
