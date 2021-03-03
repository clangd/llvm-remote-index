The Dockerfile requires clangd-index-server,
download_latest_release_assets.py, index_fetcher.sh and entry_point.sh to be in
the working directory.

The container sets up a cronjob that'll invoke index_fetcher.sh with necessary
environment variables every 6 hours and starts the clangd-index-server, which
automatically consumes the artifacts produced by index_fetcher. Hence a new
image is only needed for configuration or binary updates.
