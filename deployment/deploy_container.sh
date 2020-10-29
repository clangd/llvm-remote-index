#!/bin/bash
PROJECT_ID=llvm-remote-index
SERVICE_NAME=llvm-remote-index-server
IMAGE_NAME=llvm-remote-index-server

kubectl create deployment "$SERVICE_NAME" \
  --image="gcr.io/$PROJECT_ID/$IMAGE_NAME"
kubectl get pods

kubectl expose deployment "$SERVICE_NAME" --name="${SERVICE_NAME}-service" \
  --type=LoadBalancer --port 50051 --target-port 50051
kubectl get service
