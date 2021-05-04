#!/bin/bash

INDEX_FILE="/index.idx"
INDEX_FETCHER_CMD="/index_fetcher.sh $REPOSITORY $INDEX_ASSET_PREFIX $INDEX_FILE"
STATUS_UPDATER_CMD="/status_updater.sh $PROJECT_NAME"
INSTANCE_PORTS="50051"
STATUS_UPDATER_CMD="${STATUS_UPDATER_CMD} ${INSTANCE_PORTS}"

# Abort script on failure.
set -e
# Print commands as we execute them.
set -x

# Set the path so that cron can find j2.
echo "PATH=$PATH" > crontab_schedule.txt
# Run index fetcher once every 6 hours.
echo "0 */6 * * * $INDEX_FETCHER_CMD" >> crontab_schedule.txt
# Update status every minute.
echo "* * * * * $STATUS_UPDATER_CMD" >> crontab_schedule.txt
crontab crontab_schedule.txt
cron

# Run status updater at startup to generate error file.
$STATUS_UPDATER_CMD
# Fetch index once to start serving immediately.
$INDEX_FETCHER_CMD

# Start the nginx server. Contents in /var/www/html are served at *:80.
service nginx start
# Start the server.
/clangd-index-server $INDEX_FILE $INDEXER_PROJECT_ROOT -log-public
