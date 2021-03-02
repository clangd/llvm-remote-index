# Privacy policy

## Data pipeline

Clangd remote index server is building an index directly from public LLVM
[source code](https://github.com/llvm/llvm-project/). The [indexer
code](https://github.com/clangd/llvm-remote-index/blob/master/.github/workflows/index.yaml)
is executed by GitHub Actions and can be monitored on [clangd/llvm-remote-index
Actions](https://github.com/clangd/llvm-remote-index/actions) tab. 

## User data

The remote index service can be summarized as an implementation of
[`clang::clangd::SymbolIndex`](https://github.com/llvm/llvm-project/blob/main/clang-tools-extra/clangd/index/Index.h)
interface. The data we transfer from and to the client is the data needed to
form a request to the index instance (and doesn't differ from the analogous
request sent to the local index).
[clangd/index/remote/Index.proto](https://github.com/llvm/llvm-project/blob/main/clang-tools-extra/clangd/index/remote/Index.proto)
is a specification of data that is transferred over the wire. Even though this
data is transferred to and from the server, none if it is actually saved. The
server disposes the request data from the RAM right after the response is
sent and the only data it saves is:

* Request timestamp
* How much time it took the server to process request
* Status of the request processing (success/failure)
* Number of the results returned for each successful request

These logs help maintainers monitor and identify problems with the service and
improve it over time. We [run the
server](https://github.com/clangd/llvm-remote-index/blob/master/deployment/entry_point.sh)
with `--log-public` option within a Docker
[container](https://github.com/clangd/llvm-remote-index/blob/master/deployment/Dockerfile).
All [deployment
scripts](https://github.com/clangd/llvm-remote-index/tree/master/deployment)
are also public.

## Client and server specification

Finally, the code that runs the service as well as its client side is publicly
available. The client side implementation lives in upstream LLVM under
[clang-tools-extra/clangd/index/remote/](https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd/index/remote),
this is exactly the code being used to produce Clangd [releases and weekly
snapshots](https://github.com/clangd/clangd/releases). The server code
lives in [clangd/llvm-remote-index](https://github.com/clangd/llvm-remote-index)
repository and also has the deployment scripts. The service is deployed on the
public instance of Google Cloud Platform.
