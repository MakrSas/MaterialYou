#!/bin/sh
# Builds the macOS dump tool from the port and compares it with the Java reference.
set -e
cd "$(dirname "$0")/.."
xcrun clang -O1 -fobjc-arc -framework Foundation -I. MCU*.m tests/dump.m -o /tmp/lqs-monet-dump
/tmp/lqs-monet-dump > /tmp/lqs-monet-out.tsv
grep -v '^score' tests/ref.tsv > /tmp/lqs-monet-ref.tsv
total=$(wc -l < /tmp/lqs-monet-ref.tsv)
bad=$(diff /tmp/lqs-monet-ref.tsv /tmp/lqs-monet-out.tsv | grep -c '^>' || true)
echo "values: $total, mismatching lines: $bad"
diff /tmp/lqs-monet-ref.tsv /tmp/lqs-monet-out.tsv | head -20 || true
