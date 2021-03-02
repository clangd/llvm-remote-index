# Terms and Conditions

Clangd remote index service is run on a best-effort basis by Clangd developers
team. Google donates VM instances in GCP to the LLVM Foundation for hosting
this service, and is not tied to it in any other way. We also monitor the
service on a best-effort basis and will do our best to deal with arising
problems (such as server not being responsive) within several working days. We
understand that productivity of remote index users would be affected in case of
the server downtime and hence we will ensure that if the service is not
responsive it will not stay down for more than 1 workday.

The service is aimed to improve the workflow of LLVM contributors and relieve
the burden of having to use a very powerful machine for editing code by
off-loading one of the most expensive operations -- codebase indexing. Remote
index service offers a way to maintain a connection with the infrastructure that
keeps relatively fresh LLVM index (rebuilt and updated daily) and use it in
combination with Clangd, so that users can take advantage of its features such
as code completion, code navigation (go-to-definition, find references) and so
on.

For more information about remote index feature and its design, please see
[documentation](https://clangd.llvm.org/remote-index.html).

Both the service and the code it runs are available publicly for all interested
parties. Please check the [privacy document](domain/privacy) to
learn more about how we keep your data secure and where you can inspect the
code.

To get in touch with the developers, report bugs and ask questions, please open
GitHub Issue:
[clangd/llvm-remote-index](https://github.com/clangd/llvm-remote-index/issues).
