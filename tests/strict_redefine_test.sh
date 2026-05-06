#!/bin/bash
# Test for $STRICT_REDEFINE (latex2html.pin patch).
#
# Default mode: \newcommand collisions with do_cmd_X handlers print a warning
# but the build continues (long-standing latex2html behaviour).
#
# Strict mode ($STRICT_REDEFINE=1): collisions print "*** FATAL" and the
# build exits with RC=1, surfacing the hidden corruption that would
# otherwise silently render \cmd as raw arguments concatenated.
#
# Requires a do_cmd_qsp handler from an init file. We synthesize a minimal
# one inline so the test is self-contained and does not depend on jos-latex.

set -e
cd "$(dirname "$0")"

LATEX2HTML="${LATEX2HTML:-/l/l2h/latex2html}"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# Init file that defines a do_cmd_qsp handler, mimicking any project's
# init file that registers HTML output handlers for latex commands.
cat > "$TMP/init_default.pl" <<'EOF'
sub do_cmd_qsp { local($_)=@_; join('', ' ', $_); }
1;
EOF

cat > "$TMP/init_strict.pl" <<'EOF'
sub do_cmd_qsp { local($_)=@_; join('', ' ', $_); }
$STRICT_REDEFINE = 1;
1;
EOF

# Pre-latex so the .aux file exists.
latex -output-directory "$TMP" strict_redefine_test.tex >/dev/null 2>&1
cp strict_redefine_test.tex "$TMP/"

run_l2h() {
    local init=$1 outdir=$2
    mkdir -p "$outdir"
    cd "$TMP"
    "$LATEX2HTML" -dir "$outdir" -init_file "$init" strict_redefine_test.tex \
        > "$outdir.log" 2>&1
    local rc=$?
    cd - >/dev/null
    return $rc
}

fail=0

# Default mode: should succeed.
if run_l2h "$TMP/init_default.pl" "$TMP/out_default"; then
    echo "PASS: default mode build succeeded (RC=0)"
else
    echo "FAIL: default mode build failed (RC=$?)"
    fail=1
fi

# Strict mode: should exit non-zero and print FATAL.
if run_l2h "$TMP/init_strict.pl" "$TMP/out_strict"; then
    echo "FAIL: strict mode should have exited non-zero on collision"
    fail=1
else
    if grep -q '^\*\*\* FATAL: \\newcommand{\\qsp}' "$TMP/out_strict.log"; then
        echo "PASS: strict mode exited non-zero with FATAL message"
    else
        echo "FAIL: strict mode exited non-zero but FATAL message not found"
        fail=1
    fi
fi

exit $fail
