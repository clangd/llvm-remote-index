#!/bin/bash
TARGET="$1"
IMAGE_FQN="$2"

function printUsage() {
  echo "Usage: $0 [staging | live] IMAGE_FQN"
  echo " You can retrieve image fqn via 'gcloud container images list-tags IMAGE_NAME'"
  echo " followed by 'gcloud container images describe IMAGE_NAME@sha265:DIGEST'"
  exit 1
}

case $TARGET in
  staging)
    # Always create a new docker image when pushing to staging.
    bash push_new_docker_image.sh
    ;;
  live)
    ;;
  *)
    printUsage
    ;;
esac
if [ -z "$IMAGE_FQN" ]; then
  printUsage
fi

source args.sh
source instance_group_management.sh

rolloutImage $IMAGE_FQN $TARGET
