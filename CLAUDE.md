# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Configure (generates cfgcache.pm and Makefile)
./configure --prefix="$PWD/local"

# Build all scripts from .pin templates
make

# Build with development options
make devel

# Clean generated files
make clean
make distclean   # Full cleanup including config
```

## Testing

```bash
# Syntax check all Perl files
make check

# Run default test (l2htest)
make test

# Run specific test case
make test TESTCASE=basic.tex

# Pass arguments to latex2html
make test ARGS='-debug'

# Test pstoimg specifically
make test_pstoimg

# Clean test output
make test_clean
```

## Architecture

LaTeX2HTML is a Perl-based translator that converts LaTeX documents to HTML.

### Build System

The build uses a **preprocessor pattern**:
- `.pin` templates → executable scripts via `config/build.pl`
- `@MARKER@` placeholders in .pin files get replaced with values from `cfgcache.pm`
- Never edit generated scripts (`latex2html`, `pstoimg`, `texexpand`, `l2hconf.pm`) directly

### Key Source Files

| Template | Generated | Purpose |
|----------|-----------|---------|
| `latex2html.pin` | `latex2html` | Main translator (~17K lines) |
| `pstoimg.pin` | `pstoimg` | PostScript to image converter |
| `texexpand.pin` | `texexpand` | TeX macro expander |
| `l2hconf.pin` | `l2hconf.pm` | Configuration module |

### Module Directories

- **styles/** - LaTeX package handlers (98 `.perl` files: amsmath, graphics, hyperref, etc.)
- **versions/** - HTML output format modules (html2_2.pl through html4_1.pl, math.pl, i18n.pl)
- **L2hos/** - OS abstraction (Unix.pm, Mac.pm, Win32.pm, Dos.pm, OS2.pm)
- **tests/** - Test `.tex` files and generated output

### Configuration Hierarchy

1. `l2hconf.pm` (site-wide, generated from l2hconf.pin)
2. `~/.latex2html-init` (user-level, optional)
3. `./.latex2html-init` (project-level, optional)

Template for user config: `dot.latex2html-init`

### External Dependencies

- **LaTeX**: latex, dvips
- **Ghostscript**: gs (pnmraw/ppmraw device)
- **Netpbm**: pnmcrop, pnmtopng, ppmtogif, etc.
- **Perl**: 5.003+

## Code Style

- `use strict; use warnings;` at file top
- Tab indentation with braces on own lines
- Single quotes for non-interpolated strings
- Module names: CamelCase (`L2hos.pm`)
- Package variables: `$UPPER_CASE`
- Verify syntax: `perl -c path/to/file.pm`

## Testing Guidelines

- Run `make check` and `make test` before commits
- Add regression test cases as `.tex` files in `tests/`
- Keep tests deterministic (no network, local fonts)
- Include before/after HTML snippets for visual changes in PRs

## Commit Style

Imperative subject lines under 70 chars:
- "Fix equation numbering mismatch"
- "Avoid redundant -scale arguments"
- "Escape brace for newer Perl"
