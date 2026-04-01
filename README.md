Add MathJax support to latex2html-2012

## Build/Install Note

Several key scripts (`pstoimg`, `latex2html`, `texexpand`, `l2hconf`)
are generated from `.pin` source files (e.g., `pstoimg.pin`) during
`./configure` and `make install`. The installed copies in
`/usr/local/bin/` should be kept in sync with the tracked `.pin`
source files in this repository. After modifying a `.pin` file, re-run
`./configure && make install` to regenerate and install the
corresponding scripts.
