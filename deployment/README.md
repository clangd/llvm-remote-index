# GCP server management scripts

This directory contains scripts used for managing the GCP project. They make use
of Google Cloud SDK so you need to install the SDK first, you can find
instructions [here](https://cloud.google.com/sdk/docs/install).

## Configuration

Most of the configuration arguments for GCP deployment are defined in
[args.sh](args.sh). You can see documentation and different setup options in
this script.

### Serving infra

[initial_setup.sh](initial_setup.sh) handles creation of VM instances and load
balancers. It should be run once, by default it will create 2 serving
environments, one for live and one for staging.

Staging environment consists of a single instance group and a single VM in
europe-west, with a regional TCP loadbalancer in front. Loadbalancer accepts
trafic on port 50051.

Live environment has 2 instance groups one in us-central other in europe-west,
with a single VM in each of them. It has a global TCP loadbalancer in front.
Loadbalancer accepts traffic on port 5900.

Both environments use a TCP healthcheck on port 50051 and they only allow
ingress to that port.

## Rolling images back/forward

For moving to the new release or falling back to the old one use
[rollout_new_release.sh](rollout_new_release.sh) and
[rollback_to_release.sh](rollback_to_release.sh) respectively.

### Rolling out new images

`bash rollout_new_release.sh staging` will create a new docker image, pulling
the binaries from
[clangd/clangd/releases](https://github.com/clangd/clangd/releases) page, and
push it to staging.

`bash rollout_new_release.sh live` will push the latest available docker image
in Google Container Registry (GCR) into live, e.g. can be used to promote the
latest staging image.

### Rolling back to older images

`bash rollback_to_release.sh [staging|live] IMAGE_FQN` can be used to change
images for staging|live instaces.

Fully qualified image names (FQN) can be acquired either through GCP web UI or
through SDK with:

```
gcloud container images list-tags gcr.io/llvm-remote-index/llvm-remote-index-server
gcloud container images describe gcr.io/llvm-remote-index/llvm-remote-index-server@sha265:$SHORT_SHA$
```
