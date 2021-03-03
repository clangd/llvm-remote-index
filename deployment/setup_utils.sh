#!/bin/bash
source args.sh

# Creates a TCP health check on port 50051 in specified region with given name.
function createHealthCheck() {
  local HC_REGION="$1"
  local HC_NAME="$2"
  if [ "$HC_REGION" = "global" ]; then
    HC_REGION="--global"
  else
    HC_REGION="--region=${HC_REGION}"
  fi

  # Create tcp health check on port 50051.
  gcloud beta compute health-checks create tcp $HC_NAME --project=$PROJECT_ID \
    --port=50051 --proxy-header=NONE --no-enable-logging $HC_REGION \
    --check-interval=10 --timeout=5 --unhealthy-threshold=3 \
    --healthy-threshold=1
}

# Creates a TCP load balancer in given region. Uses a reverse tcp proxy for
# global loadbalancers.
function createLoadBalancer() {
  local LB_NAME="$1"
  local REGION="$2"
  local LB_PORT="$3"
  local HC_NAME="$4"
  local NAMED_PORT="$5"
  local PROXY_NAME="${LB_NAME}-tcp-proxy"
  local IPV4_NAME="${LB_NAME}-ipv4"

  if [ "$REGION" = "global" ]; then
    local LB_REGION="--${REGION}"
    HC_REGION="--global-health-checks"
    local IP_VERSION="--ip-version=IPV4"
  else
    HC_REGION="--health-checks-region=${REGION}"
    local LB_REGION="--region=${REGION}"
    # Regional load balancers don't get to choose between ipv4 and ipv6.
    local IP_VERSION=""
  fi

  # First create the backend service to which instance groups will be attached
  # later on.
  gcloud compute --project=$PROJECT_ID backend-services create $LB_NAME \
    $HC_REGION $LB_REGION --protocol="TCP" --health-checks=$HC_NAME \
    --port-name=$NAMED_PORT

  # Create an ip for the LB frontend.
  gcloud compute --project=$PROJECT_ID addresses create $IPV4_NAME $LB_REGION \
    $IP_VERSION

  if [ "$REGION" = "global" ]; then
    # Create a TCP proxy.
    gcloud compute --project=$PROJECT_ID target-tcp-proxies create $PROXY_NAME \
      --backend-service=$LB_NAME --proxy-header NONE
    # Create a forwarding rule from frontend to tcp proxy.
    gcloud compute --project=$PROJECT_ID forwarding-rules create \
      "${IPV4_NAME}-forwarding-rule" --global --target-tcp-proxy=$PROXY_NAME \
      --address=$IPV4_NAME --ports=$LB_PORT
  else
    # Create a forwarding rule from frontend to backend service directly.
    gcloud compute --project=$PROJECT_ID forwarding-rules create \
      "${IPV4_NAME}-forwarding-rule" --load-balancing-scheme external \
    --region=$REGION --ports=$LB_PORT --address=$IPV4_NAME \
    --backend-service=$LB_NAME
  fi
}

# Creates an instance group with the given template in given region and adds it
# as a backend service for the given load balancer.
function addBackendToLB() {
  local LB_NAME="$1"
  local IG_NAME="$2"
  local IG_ZONE="$3"
  local REGION="$4"
  local TEMPLATE_NAME="$5"
  local HC_NAME="$6"
  local NAMED_PORT="$7"
  if [ "$REGION" = "global" ]; then
    local LB_REGION="--${REGION}"
  else
    local LB_REGION="--region=${REGION}"
  fi

  # Create a managed instance group, with given name in given zone.
  gcloud compute --project=$PROJECT_ID instance-groups managed create $IG_NAME \
    --base-instance-name=$IG_NAME --template=$TEMPLATE_NAME --size=1 \
    --zone=$IG_ZONE --health-check=$HC_NAME --initial-delay=300

  # Also add the named port for load balancer use.
  gcloud compute --project=$PROJECT_ID instance-groups set-named-ports \
    $IG_NAME --named-ports="${NAMED_PORT}:50051" --zone=$IG_ZONE

  # Add the instance group as a backend to the load balancer.
  gcloud compute --project=$PROJECT_ID backend-services add-backend \
    $LB_NAME $LB_REGION --instance-group=$IG_NAME --instance-group-zone=$IG_ZONE
}
