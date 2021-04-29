# !/bin/bash

source args.sh

PUB_SUB_TOPIC="deploy-index-server"
gcloud pubsub topics create --project=$PROJECT_ID $PUB_SUB_TOPIC

# Create a periodic task that will trigger a new deployment 9AM UTC every
# Wednesday.
gcloud scheduler jobs create pubsub --project=$PROJECT_ID \
  "deployment-scheduler" --schedule="0 9 * * 3" --topic=$PUB_SUB_TOPIC \
  --message-body="Deploy"

RED='\033[0;31m'
NC='\033[0m' # No Color

set +x
# TODO: Create this automatically through gcloud cli once it is possible.
echo -en "${RED}WARNING:${NC} "
echo "You need to create a build trigger that'll listen on $PUB_SUB_TOPIC and"
echo "associate it with $INDEX_REPO in"
echo "https://console.cloud.google.com/cloud-build/triggers/add?project=${PROJECT_ID}"
echo

echo -en "${RED}WARNING:${NC} "
echo "You also need to add Compute Instance Admin, Compute Load Balancer Admin"
echo "and Service Account User roles to cloudbuild service account in"
echo "https://console.cloud.google.com/iam-admin/iam?project=${PROJECT_ID}"
