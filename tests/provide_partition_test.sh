#!/bin/bash
# Regression test for $PARTITION_PAST_PREAMBLE (latex2html.pin):
# \providecommand-defined macros must be substituted in document body that
# arrives via \input.
#
# Bug: latex2html splits its (texexpand'ed) input into partitions at each
# included file and runs substitute_meta_cmds on each.  A partition starts
# with $within_preamble = 1 ($PREAMBLE is still 2 while the input is being
# read) and clears it only on meeting \begin{document}, which partitions
# after the first never contain.  substitute_meta_cmds "leaves alone" any
# \providecommand macro while $within_preamble, so in every \input'ed body
# file such macros stayed raw.  With $USE_MATHJAX the math body is emitted
# as raw TeX, so the browser showed them as red undefined commands (\mr,
# \mrr in the filters book, whose trig.tex arrives via \input).  A
# \newcommand with the same body was substituted fine.
#
# Self-contained: a preamble \providecommand, the use inside a math display
# in an \input'ed file, $USE_MATHJAX = 1 in an inline init file.

set -e
cd "$(dirname "$0")"

LATEX2HTML="${LATEX2HTML:-/l/l2h/latex2html}"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cat > "$TMP/init.pl" <<'EOF'
$USE_MATHJAX = 1;
1;
EOF

cat > "$TMP/provide_partition_test.tex" <<'EOF'
\documentclass{article}
\usepackage{html}
\providecommand{\pvrow}[2]{\displaystyle#1&=&#2\\[2pt]}
\newcommand{\nwrow}[2]{\displaystyle#1&=&#2\\[2pt]}
\providecommand{\pvsym}{PVSYMOK}
\begin{document}
\section{Provide-partition test}
Inline use (same partition): $\pvsym$.
\input{provide_partition_body.tex}
\end{document}
EOF

cat > "$TMP/provide_partition_body.tex" <<'EOF'
Body file (own partition): $\pvsym$.
\[
\begin{array}{rcl}
\pvrow{a}{b}
\nwrow{c}{d}
\end{array}
\]
EOF

(
    cd "$TMP"
    latex -interaction=batchmode provide_partition_test.tex >/dev/null 2>&1 || true
    mkdir -p out
    "$LATEX2HTML" -dir "$TMP/out" -init_file "$TMP/init.pl" -split 0 \
        provide_partition_test.tex > "$TMP/out.log" 2>&1
)

html=$(cat "$TMP"/out/*.html)
fail=0
check() {
    local what=$1 needle=$2
    case "$html" in
        *"$needle"*) echo "PASS: $what";;
        *) echo "FAIL: $what (expected '$needle' in output; see $TMP/out.log)"; fail=1;;
    esac
}
absent() {
    local what=$1 needle=$2
    case "$html" in
        *"$needle"*) echo "FAIL: $what ('$needle' still present in output)"; fail=1;;
        *) echo "PASS: $what";;
    esac
}

check  "\\providecommand macro substituted in \\input'ed math" 'a&=&b'
check  "\\newcommand macro substituted in \\input'ed math (control)" 'c&=&d'
absent "no raw \\pvrow in output" '\pvrow'
check  "0-arg \\providecommand macro substituted in \\input'ed text" 'PVSYMOK'
absent "no raw \\pvsym in output" '\pvsym'

[ $fail = 0 ] || exit 1
