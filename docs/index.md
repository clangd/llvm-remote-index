# LLVM remote index server

This server provides about a day old index for
[llvm-project](https://github.com/llvm/llvm-project/) to be used by
clangd. It aims to lower resource usage of clangd on workstation machines by
moving project-wide indexing and serving pieces to a centralized server.

To make use of this service you need a clangd build with remote index support
and point clangd at this particular index server.

More details on
[remote index internals](https://clangd.llvm.org/remote-index.html).

## Getting clangd client

[clangd/releases](https://github.com/clangd/clangd/releases) are
built with that support for major platforms. You can find out about other
options in [here](https://clangd.llvm.org/remote-index.html#clangd-client).

After acquiring the binary, make sure your LSP client points to it. Details
about this process can be found
[here](https://clangd.llvm.org/installation.html#editor-plugins).

## Pointing clangd to llvm-remote-index-server

Finally you'll need to point clangd at this particular index server. The easiest
way to achieve this is via user configuration: a config.yaml file in an
OS-specific directory:

-   Windows: `%LocalAppData%\clangd\config.yaml`, typically
    `C:\Users\Bob\AppData\Local\clangd\config.yaml`.
-   macOS: `~/Library/Preferences/clangd/config.yaml`
-   Linux and others: `$XDG_CONFIG_HOME/clangd/config.yaml`, typically
    `~/.config/clangd/config.yaml`.

You'll need to populate this config file with the following, while changing
`/path/to/llvm/` with absolute path to your checkout location.

```
If:
  PathMatch: /path/to/llvm/.*
Index:
  External:
    Server: clangd-index.llvm.org:5900
    MountPoint: /path/to/llvm/
```

If you have multiple checkouts you can specify different fragments by putting
`---` in between. You can also turn on local indexing for parts of the codebase
to have up-to-date symbol information. Such a config file could look like:

```
If:
  PathMatch: /path/to/llvm/.*
Index:
  External:
    Server: clangd-index.llvm.org:5900
    MountPoint: /path/to/llvm/
---
If:
  PathMatch: /path/to/llvm/clang-tools-extra/clangd/.*
Index:
  Background: Build
```

Note that the fragment setting `Index.Background` to `Build` must come
**after** the external index specification. More details on [configuration
schema](https://clangd.llvm.org/config.html).
