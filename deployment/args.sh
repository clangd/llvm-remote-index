#!/bin/bash
# Abort script on failure and print commands as we execute them.
set -x -e

# GCP project to configure.
PROJECT_ID="llvm-remote-index"

# Basename for instance templates, can be suffixed with image SHAs.
BASE_TEMPLATE_NAME="${PROJECT_ID}-server-template"

# Machine type to use for index serving VM instances.
# 2 vCPUs and 4GB ram is enough for serving llvm-index.
# https://cloud.google.com/compute/docs/machine-types#e2_standard_machine_types
MACHINE_TYPE="e2-medium"

# Fully qualified name for the server image in GCR.
IMAGE_IN_GCR="gcr.io/${PROJECT_ID}/${PROJECT_ID}-server"

# Used as base name for instance groups and machine instances.
BASE_INSTANCE_NAME="${PROJECT_ID}-server"

# Following options are used by push_new_docker_image.sh to configure container
# for fetching new index artifacts and consuming them.

# Which github repository to use for fetching index artifacts.
INDEX_REPO="clangd/llvm-remote-index"

# Artifact prefix to fetch the index from and port number to serve it on.
# Separated by `:`.
INDEX_ASSET_PORT_PAIRS="llvm-index:50051"

# Absolute path to project root on indexer machine, passed to
# clangd-index-server.
INDEXER_PROJECT_ROOT="/home/runner/work/llvm-remote-index/llvm-remote-index/llvm-project/"
