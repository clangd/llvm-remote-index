#!/bin/bash
source args.sh
source setup_utils.sh

# Create one server image, push it to the GCR first and create an instance
# template using that container.
bash push_new_docker_image.sh
IMAGE_SHA=$(gcloud container images list-tags $IMAGE_IN_GCR --format=yaml --limit=1 | grep -i digest | cut -d' ' -f2)
SHORT_SHA=$(echo $IMAGE_SHA | cut -d: -f2 | head -c 8)
IMAGE_FQN="${IMAGE_IN_GCR}@${IMAGE_SHA}"
TEMPLATE_NAME="${BASE_TEMPLATE_NAME}-${SHORT_SHA}"
bash create_vm_template.sh $IMAGE_FQN $TEMPLATE_NAME

# Create the firewall rule to allow ingress into the server on port 50051.
gcloud compute --project=$PROJECT_ID firewall-rules create \
  "${BASE_INSTANCE_NAME}-fw-grpc" --direction=INGRESS --priority=1000 \
  --action=ALLOW --rules=tcp:50051 --source-ranges=0.0.0.0/0 \
  --target-tags=$BASE_INSTANCE_NAME

# We need two healthchecks, one global for live instance and one regional for
# staging.
HEALTH_CHECK_NAME="${BASE_INSTANCE_NAME}-hc-grpc"
createHealthCheck "global" $HEALTH_CHECK_NAME
createHealthCheck "europe-west1" $HEALTH_CHECK_NAME

# Create one staging instance and 2 production instances, with appropriate load
# balancers.

# Named port for load balancer to redirect traffic into instance groups.
NAMED_PORT="grpc"

# Create staging instance with a single VM and frontend on port 50051.
IG_NAME="${BASE_INSTANCE_NAME}-staging"
LB_NAME="${IG_NAME}-lb"
createLoadBalancer $LB_NAME "europe-west1" 50051 $HEALTH_CHECK_NAME $NAMED_PORT
addBackendToLB $LB_NAME "${IG_NAME}-eu" "europe-west1-b" "europe-west1" \
  $TEMPLATE_NAME $HEALTH_CHECK_NAME $NAMED_PORT

# Now create the live instance with 2 VMs and frontend on port 5900.
IG_NAME="${BASE_INSTANCE_NAME}-live"
LB_NAME="${IG_NAME}-lb"
createLoadBalancer $LB_NAME "global" 5900 $HEALTH_CHECK_NAME $NAMED_PORT
addBackendToLB $LB_NAME "${IG_NAME}-eu" "europe-west1-b" "global" \
  $TEMPLATE_NAME $HEALTH_CHECK_NAME $NAMED_PORT
addBackendToLB $LB_NAME "${IG_NAME}-us" "us-central1-b" "global" \
  $TEMPLATE_NAME $HEALTH_CHECK_NAME $NAMED_PORT
