#!/usr/bin/env bash
# Fail the build when a _redirects entry has no usable redirect_to, or when
# two entries would collide on the same slug (.md vs .markdown).
set -uo pipefail

status=0
for f in _redirects/*; do
  if ! grep -qE '^redirect_to:[[:space:]]*"?https?://[^"[:space:]]+"?[[:space:]]*$' "$f"; then
    echo "::error file=$f::missing or invalid redirect_to (must be an absolute http(s) URL)"
    status=1
  fi
done

dups=$(find _redirects -maxdepth 1 -type f | sed -E 's#.*/##; s/\.(md|markdown)$//' | sort | uniq -d)
if [ -n "$dups" ]; then
  echo "::error::duplicate slugs in _redirects: $(echo "$dups" | tr '\n' ' ')"
  status=1
fi

exit $status
