FROM debian:stable
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y cron python3 python3-requests unzip nginx-light
# We install pip, jinja and delete pip afterwards in same step to keep final
# image size small.
RUN apt-get install -y --no-install-recommends python3-pip && \
  pip3 install j2cli && apt-get remove -y python3-pip && apt-get autoremove -y
RUN rm -rf /var/www/html/*
WORKDIR "/"

ARG REPOSITORY
ENV REPOSITORY ${REPOSITORY}
ARG INDEX_ASSET_PORT_PAIRS
ENV INDEX_ASSET_PORT_PAIRS ${INDEX_ASSET_PORT_PAIRS}
ARG INDEXER_PROJECT_ROOT
ENV INDEXER_PROJECT_ROOT ${INDEXER_PROJECT_ROOT}
ARG PROJECT_NAME
ENV PROJECT_NAME ${PROJECT_NAME}

ADD "clangd-index-server" "clangd-index-server"
ADD "clangd-index-server-monitor" "clangd-index-server-monitor"
ADD "status_templates" "/status_templates"
ADD "docs" "/docs"
ADD "download_latest_release_assets.py" "download_latest_release_assets.py"
ADD "index_fetcher.sh" "index_fetcher.sh"
ADD "entry_point.sh" "entry_point.sh"
ADD "status_updater.sh" "status_updater.sh"

ENTRYPOINT ["/entry_point.sh"]
