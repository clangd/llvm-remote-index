# llvm-remote-index

[![Index LLVM project](https://github.com/clangd/llvm-remote-index/workflows/Index%20LLVM%20project/badge.svg)](https://github.com/clangd/llvm-remote-index/actions)

Scripts for running and maintaining the
[LLVM Remote Index Service](http://clangd-index.llvm.org/).

## Repo Layout

[deployment](deployment/) contains the script used to deploy a remote-index
serving instance to GCP. It takes care of VM creation and deploying new docker
containers.

[docker](docker/) contains the scripts used by remote-index serving instance to
fetch new index files and startup the clangd-index-server. It also contains the
Dockerfile that containerizes this process.
