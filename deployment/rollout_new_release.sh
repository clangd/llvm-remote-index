#!/bin/bash
source args.sh
source instance_group_management.sh

TARGET="$1"

case $TARGET in
  staging)
    # Always create a new docker image when pushing to staging.
    bash push_new_docker_image.sh
    ;;
  live)
    ;;
  *)
    echo "Usage: $0 [staging | live]"
    exit 1
esac

# Fetch latest image sha from GCR.
IMAGE_SHA=$(gcloud container images list-tags $IMAGE_IN_GCR --format=yaml --limit=1 | grep -i digest | cut -d' ' -f2)
IMAGE_FQN="${IMAGE_IN_GCR}@${IMAGE_SHA}"
rolloutImage $IMAGE_FQN $TARGET
