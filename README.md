# llvm-remote-index

[![Index LLVM project](https://github.com/clangd/llvm-remote-index/workflows/Index%20LLVM%20project/badge.svg)](https://github.com/clangd/llvm-remote-index/actions)

# Creating a docker image

Running `bash deployment/create_docker_image.sh` will create a new container for
index server. It will fetch the latest released server binary from
[clangd/clangd/](github.com/clangd/clangd). The image is automatically tagged as
llvm-remote-index-server:latest.

Container will set up a cron job at startup to fetch latest LLVM index from
[clangd/llvm-remote-index](https://github.com/clangd/llvm-remote-index) every 6
hours. Afterwards it will start index-server, which will pick up the new index
everytime it changes.
