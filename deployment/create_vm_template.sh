#!/bin/bash

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 FULL_IMAGE TEMPLATE_NAME"
  echo "  FULL_IMAGE - Full name of the image in GCR."
  echo "  TEMPLATE_NAME - Name to use for VM instance template."
  exit 1
fi

source args.sh
FULL_IMAGE="$1"
TEMPLATE_NAME="$2"

if gcloud compute --project=$PROJECT_ID instance-templates describe $TEMPLATE_NAME;
then
  echo "Template already exists, using it."
  exit 0
fi

gcloud compute --project=$PROJECT_ID instance-templates \
  create-with-container $TEMPLATE_NAME --machine-type=$MACHINE_TYPE \
  --metadata=google-logging-enabled=true,google-monitoring-enabled=true \
  --boot-disk-size=10GB --boot-disk-type=pd-standard \
  --tags=$BASE_INSTANCE_NAME --container-image=$FULL_IMAGE
