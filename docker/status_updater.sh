#!/bin/bash
# Issues monitoring requests on all ports of the localhost passed in as
# positional args and merges those into one final html.

TMPL_DIR="/status_templates"
HEADER_TMPL="$TMPL_DIR/header"
SUCCESS_TMPL="$TMPL_DIR/success"
FAILURE_TMPL="$TMPL_DIR/failure"
CONTACT_TMPL="$TMPL_DIR/contact"
FOOTER_TMPL="$TMPL_DIR/footer"
OUT_FILE="/var/www/html/status.html"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 PROJECT_NAME REPOSITORY PORTS..."
  echo "  PROJECT_NAME - e.g. llvm-remote-index"
  echo "  REPOSITORY - e.g. clangd/llvm-remote-index"
  echo "  NAME:PORT pairs... - One or more name:port pairs. Name is displayed \
    on the status page and port is used to query an index-server on the localhost"
  exit
fi

set -e -x

# Stores monitoring info from grpc servers.
TEMP_DATA_FILE=$(mktemp)

# Current output we are building, swapped with $OUT_FILE once it is complete.
TEMP_OUT_FILE=$(mktemp)
# Make sure it will be readable once moved to final target.
chmod a+r $TEMP_OUT_FILE

# Delete tmp files on exit.
trap "rm -f $TEMP_DATA_FILE" EXIT
trap "rm -f $TEMP_OUT_FILE" EXIT

# Env variables used by templates.
export HOST_NAME="$(hostname -s)"
export PROJECT_NAME="$1"
shift
export REPOSITORY="$1"
shift

j2 $HEADER_TMPL >> $TEMP_OUT_FILE

# All the remaining args are ports on the local machine to connect.
while [[ $# -gt 0 ]];
do
  NAME=${1%:*}
  PORT=${1#*:}
  shift
  export INSTANCE_NAME="${HOST_NAME}/${NAME}"

  if /clangd-index-server-monitor "localhost:${PORT}" > $TEMP_DATA_FILE; then
    TMPL_FILE=$SUCCESS_TMPL
  else
    TMPL_FILE=$FAILURE_TMPL
    # j2 expects a valid json file, so in case of failure to communicate with
    # server, just provide an empty json.
    echo '{}' > $TEMP_DATA_FILE
  fi

    j2 --format=json -e '' "$TMPL_FILE" "$TEMP_DATA_FILE" >> $TEMP_OUT_FILE
done

j2 $CONTACT_TMPL >> $TEMP_OUT_FILE
j2 $FOOTER_TMPL >> $TEMP_OUT_FILE

mv $TEMP_OUT_FILE $OUT_FILE
