#!/bin/bash

# Abort script on failure.
set -e
# Print commands as we execute them.
set -x

# We will prepend all the ports to listen on while starting index-server
# instances.
STATUS_UPDATER_CMD="/status_updater.sh $PROJECT_NAME $REPOSITORY"

# Move static files to serving directory.
cp -r docs/* /var/www/html/

# Start the nginx server. Contents in /var/www/html are served at *:80.
service nginx start

# Set the path so that cron can find j2.
echo "PATH=$PATH" > crontab_schedule.txt
for ASSET_PORT_PAIR in $INDEX_ASSET_PORT_PAIRS
do
  INDEX_ASSET_PREFIX=${ASSET_PORT_PAIR%:*}
  PORT=${ASSET_PORT_PAIR#*:}
  INDEX_FILE="/${INDEX_ASSET_PREFIX}.idx"
  INDEX_FETCHER_CMD="/index_fetcher.sh $REPOSITORY $INDEX_ASSET_PREFIX $INDEX_FILE"

  # Run index fetcher once every 6 hours.
  echo "0 */6 * * * $INDEX_FETCHER_CMD" >> crontab_schedule.txt
  # Start the server and keep it running.
  bash /start_server.sh "$INDEX_FETCHER_CMD" $INDEX_FILE $INDEXER_PROJECT_ROOT \
    $PORT $INDEX_ASSET_PREFIX &
  # Watch instance.
  STATUS_UPDATER_CMD="${STATUS_UPDATER_CMD} ${PORT}"
done
# Update status every minute.
echo "* * * * * $STATUS_UPDATER_CMD" >> crontab_schedule.txt
# Run status updater at startup to generate error file.
$STATUS_UPDATER_CMD

crontab crontab_schedule.txt
cron -f
