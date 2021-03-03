#!/bin/bash

INDEX_FILE="/index.idx"
INDEX_FETCHER_CMD="/index_fetcher.sh $REPOSITORY $INDEX_ASSET_PREFIX $INDEX_FILE"

# Abort script on failure.
set -e
# Print commands as we execute them.
set -x

# Run index fetcher once every 6 hours.
echo "0 */6 * * * $INDEX_FETCHER_CMD" > crontab_schedule.txt
crontab crontab_schedule.txt
cron

# Fetch index once.
$INDEX_FETCHER_CMD

# Start the server.
/clangd-index-server $INDEX_FILE $INDEXER_PROJECT_ROOT -log-public
