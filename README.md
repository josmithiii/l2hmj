# l2hmj — LaTeX2HTML with MathJax

`l2hmj` is a fork of [LaTeX2HTML](https://www.latex2html.org/)
(latex2html-2012 lineage) that renders mathematics with
[MathJax](https://www.mathjax.org/) instead of equation images.

Classic LaTeX2HTML rasterizes every equation to a PNG/GIF via
`latex -> dvips -> ghostscript -> netpbm`, leaving the LaTeX source only
in the image ALT text. That made equations:

- invisible to copy/paste (pasting a page into an LLM or editor drops
  the math entirely),
- inaccessible to screen readers,
- blurry when zoomed, and
- unsearchable in the page text.

With `l2hmj`, math is emitted as LaTeX source wrapped in MathJax
delimiters and typeset in the browser. Equations are part of the DOM:
they copy/paste with their LaTeX source intact, scale cleanly, and work
with screen readers. This toolchain builds the JOS online books
(e.g., [Mathematics of the DFT](https://ccrma.stanford.edu/~jos/mdft/),
[Physical Audio Signal Processing](https://ccrma.stanford.edu/~jos/pasp/)).

## MathJax-related features

Configuration lives in `l2hconf` (edit `l2hconf.pin`; see build note
below):

```perl
$USE_MATHJAX = 1;             # MathJax instead of math images
$MATHJAX_URL = 'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js';
%MATHJAX_MACROS = ();         # user LaTeX macros passed to MathJax
@MATHJAX_PACKAGES = ('ams', 'textmacros', 'boldsymbol');
$MATHJAX_EXTERNAL_CONFIG = 1; # shared mathjax-config.js, cached across pages
```

- **Macro pass-through** -- `\newcommand` definitions in the document
  are forwarded to MathJax's configuration so custom macros render
  client-side; built-in defaults cover common JOS-book macros.
- **TeX extension preloading** -- extensions listed in
  `@MATHJAX_PACKAGES` are preloaded rather than autoloaded, avoiding
  the async-fetch race that leaves commands like `\boldsymbol` rendered
  in red as literal text.
- **External shared config** -- with `$MATHJAX_EXTERNAL_CONFIG = 1`,
  the (potentially large) macro/config block is written once to
  `mathjax-config.js` and cached by the browser across all pages of a
  document, instead of being inlined in every page.
- **`$STRICT_REDEFINE`** (opt-in) -- flags collisions between document
  `\newcommand` definitions and LaTeX2HTML's internal `do_cmd_*`
  handlers.

Everything else is standard LaTeX2HTML: sectioning into linked pages,
cross-references, footnotes, tables of contents, index generation, and
image generation for figures (the classic `latex`/`dvips`/`gs`/netpbm
requirements still apply for non-math images).

## Installation

```bash
./configure
make install
```

### Build note: `.pin` files are the sources

Several key scripts (`latex2html`, `pstoimg`, `texexpand`, `l2hconf.pm`)
are **generated** from `.pin` source files (`latex2html.pin`,
`pstoimg.pin`, ...) by `./configure` and `make install`. After modifying
a `.pin` file, re-run:

```bash
./configure && make install
```

to regenerate and install the corresponding scripts, keeping the
installed copies (typically in `/usr/local/bin/`) in sync with the
tracked sources.

## Tests

The `tests/` directory contains LaTeX sources exercising the translator,
including `mathjax_test.tex` (MathJax math rendering) and
`strict_redefine_test.sh` (the `$STRICT_REDEFINE` check). Typical usage:

```bash
cd tests && latex2html mathjax_test.tex
```

then open the generated HTML in a browser and confirm the equations are
selectable text, not images.

## Credits and license

LaTeX2HTML was originally written by Nikos Drakos (University of Leeds),
with later development by Ross Moore, Marek Rouchal, Jens Lippmann, and
many others -- see `README` (the original) and `Changes`. MathJax
support and related fixes by Julius O. Smith III.

Licensed under the GPL-2.0 (see `LICENSE`), as inherited from
LaTeX2HTML.
