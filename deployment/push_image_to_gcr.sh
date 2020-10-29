#!/bin/bash
PROJECT_ID=llvm-remote-index
HOST_NAME="gcr.io"
IMAGE_NAME="llvm-remote-index-server"

# Abort script on failure.
set -e
# Print commands as we execute them.
set -x

gcloud auth configure-docker
docker tag "$IMAGE_NAME" "$HOST_NAME/$PROJECT_ID/$IMAGE_NAME"
docker push "$HOST_NAME/$PROJECT_ID/$IMAGE_NAME"

kubectl set image "deployment/$IMAGE_NAME" "$IMAGE_NAME=gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest"
