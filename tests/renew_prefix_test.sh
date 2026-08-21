#!/bin/bash
# Regression test for make_new_cmd_rx (latex2html.pin): a renewed command
# must be removed from the new-command alternation by WHOLE name.
#
# Bug: with \xv in %renew_command (a perl do_cmd_xv handler exists and the
# document also says \newcommand{\xv}), the old
#     s/(^|$CD)$renew//
# stripped "xv" as a PREFIX of whichever entry came first in hash order,
# so "xvnu" could become "nu": \xvnu was then never substituted in running
# text (it reached the output raw -- red "\xvnu" under MathJax) and \nu
# silently became a "new command".  renew_prefix_test.tex has ten such
# (renewed, victim) pairs.  (A renewed name is itself NOT in %new_command
# in this setup, so the prefix match always hits the victim; we still run
# under several hash seeds because the order of the alternation is
# hash-dependent and the old code's damage varied with it in practice.)
#
# The victims are used in math under $USE_MATHJAX = 1: math bodies are then
# emitted as raw TeX, so the regex pass in substitute_meta_cmds is the only
# substitution they get (in running text the bug is masked, because
# process_command later looks the macro up by name).
#
# Self-contained: the init file synthesizes the do_cmd_* handlers inline.

set -e
cd "$(dirname "$0")"

LATEX2HTML="${LATEX2HTML:-/l/l2h/latex2html}"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

RENEWED="xv av bv cv dv ev fv gv hv kv"
VICTIMS="XVNU AVT BVQ CVR DVS EVT FVU GVW HVX KVY"

# Init file: one perl handler per renewed name, so that each document
# \newcommand{\NAME} collides with it and lands in %renew_command.
{
    echo '$USE_MATHJAX = 1;'
    for cmd in $RENEWED; do
        echo "sub do_cmd_$cmd { local(\$_)=@_; join('', '$cmd-handler', \$_); }"
    done
    echo "1;"
} > "$TMP/init.pl"

# Pre-latex so the .aux file exists.
latex -output-directory "$TMP" renew_prefix_test.tex >/dev/null 2>&1
cp renew_prefix_test.tex "$TMP/"

fail=0
for seed in 0 1 2 3; do
    out="$TMP/out_$seed"
    mkdir -p "$out"
    (
        cd "$TMP"
        PERL_HASH_SEED=$seed PERL_PERTURB_KEYS=0 \
            "$LATEX2HTML" -dir "$out" -init_file "$TMP/init.pl" -split 0 \
            renew_prefix_test.tex > "$out.log" 2>&1
    ) || { echo "FAIL: seed $seed: latex2html exited non-zero (see $out.log)"; fail=1; continue; }
    html=$(cat "$out"/*.html)
    missing=""
    for v in $VICTIMS; do
        case "$html" in *"$v-OK"*) ;; *) missing="$missing $v";; esac
    done
    if [ -n "$missing" ]; then
        echo "FAIL: seed $seed: victim macro(s) not substituted:$missing"
        fail=1
    else
        echo "PASS: seed $seed: all 10 prefixed macros substituted"
    fi
done

exit $fail
