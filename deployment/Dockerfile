FROM debian:stable
RUN apt-get update && apt-get install -y cron python3 python3-requests unzip
WORKDIR "/"

ARG REPOSITORY
ENV REPOSITORY ${REPOSITORY}
ARG INDEX_ASSET_PREFIX
ENV INDEX_ASSET_PREFIX ${INDEX_ASSET_PREFIX}
ARG INDEXER_PROJECT_ROOT
ENV INDEXER_PROJECT_ROOT ${INDEXER_PROJECT_ROOT}

ADD "clangd-index-server" "clangd-index-server"
ADD "download_latest_release_assets.py" "download_latest_release_assets.py"
ADD "index_fetcher.sh" "index_fetcher.sh"
ADD "entry_point.sh" "entry_point.sh"

ENTRYPOINT ["/entry_point.sh"]
