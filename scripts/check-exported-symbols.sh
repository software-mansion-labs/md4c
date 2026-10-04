#!/bin/bash
#
# Verify the libraries export nothing but this fork's prefixed symbols.
#
# This fork gets embedded into applications which may link another copy of MD4C
# at the same time (enriched-markdown#846), so every global the libraries define
# has to carry the ENRMRKD_/enrmrkd_ prefix, or the two copies collide at link
# time. An unprefixed global typically arrives with a merge from upstream, where
# the public functions are still named md_xxx(); scripts/rename-upstream-symbols.pl
# applies the mapping.
#
# Only the libraries are checked. The md2html utility is a standalone program,
# not something a consumer links, so its own globals (main, cmdline_read) are
# allowed to keep their upstream names.
#
# Usage: scripts/check-exported-symbols.sh [BUILD_DIR]    (default: .)

set -euo pipefail

build_dir="${1:-.}"

if ! command -v nm >/dev/null 2>&1; then
    echo "nm not found; skipping the exported symbol check" >&2
    exit 0
fi

objects=$(find "$build_dir/src" -name '*.o' 2>/dev/null | sort || true)
if [ -z "$objects" ]; then
    echo "no object files under $build_dir/src -- build the libraries first" >&2
    exit 2
fi

# Some platforms (e.g. MacOS) prefix C symbols with an underscore.
unexpected=$(nm -g --defined-only $objects \
             | awk 'NF >= 3 { print $3 }' \
             | grep -vE '^_?enrmrkd_' | sort -u || true)

if [ -n "$unexpected" ]; then
    echo "FAIL: the libraries define globals without the enrmrkd_ prefix:"
    echo "$unexpected" | sed 's/^/    /'
    echo
    echo "Each of these would collide with another MD4C copy linked into the same"
    echo "application. Rename them (scripts/rename-upstream-symbols.pl knows the"
    echo "mapping for upstream names) or make them static if they are internal."
    exit 1
fi

echo "PASS: every global defined by the libraries is enrmrkd_*:"
nm -g --defined-only $objects | awk 'NF >= 3 { print "    " $3 }' | sort -u
