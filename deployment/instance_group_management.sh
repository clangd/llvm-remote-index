#!/bin/bash
source args.sh

function updateIG() {
  local IG_NAME="$1"
  local IG_REGION="$2"
  # Update instance group to use the new image, creating 1 backup instance for
  # transition.
  gcloud beta compute --project=$PROJECT_ID instance-groups managed \
    rolling-action start-update $IG_NAME --version=template=$TEMPLATE_NAME \
    --max-surge=1 --zone=$IG_REGION --min-ready=10m --max-unavailable=1
}

function rolloutImage() {
  local IMAGE_FQN="$1"
  local TARGET="$2"
  local IG_BASE="${BASE_INSTANCE_NAME}-${TARGET}"
  local SHORT_SHA=$(echo $IMAGE_FQN | cut -d: -f2 | head -c 8)
  local TEMPLATE_NAME="${BASE_TEMPLATE_NAME}-${SHORT_SHA}"
  bash create_vm_template.sh $IMAGE_FQN $TEMPLATE_NAME

  if [ "$TARGET" = "staging" ]; then
    updateIG "${IG_BASE}-eu" "europe-west1-b"
  else
    updateIG "${IG_BASE}-eu" "europe-west1-b"
    updateIG "${IG_BASE}-us" "us-central1-b"
  fi
}
