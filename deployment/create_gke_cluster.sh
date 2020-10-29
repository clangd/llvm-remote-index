#!/bin/bash
PROJECT_ID="llvm-remote-index"
ZONE="europe-west3-c"

gcloud beta container --project $PROJECT_ID clusters \
  create "${PROJECT_ID}-cluster" --zone "$ZONE" --machine-type "e2-medium" \
  --num-nodes "1"

gcloud compute instances list
