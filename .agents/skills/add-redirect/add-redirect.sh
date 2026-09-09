#!/usr/bin/env bash
# Create and verify one short-link entry in _redirects/.
# Usage: add-redirect.sh <slug> <url> [--title "..."] [--description "..."] [--force]
set -euo pipefail

usage() { sed -n '2,3p' "$0" >&2; exit 2; }
slug=${1:-}; url=${2:-}
[ -n "$slug" ] && [ -n "$url" ] || usage
shift 2
title=""; description=""; force=0
while [ $# -gt 0 ]; do
  case $1 in
    --title) title=${2:-}; shift 2 ;;
    --description) description=${2:-}; shift 2 ;;
    --force) force=1; shift ;;
    *) echo "error: unknown option $1" >&2; usage ;;
  esac
done

root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "error: run this inside the repo" >&2; exit 1; }
cd "$root"

# --- slug: it becomes url.hyd.ai/<slug>/ and GitHub Pages is case-sensitive
if ! [[ $slug =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: slug '$slug' must be lowercase ASCII letters, digits and single hyphens" >&2; exit 1
fi
for existing in "_redirects/$slug.md" "_redirects/$slug.markdown"; do
  if [ -e "$existing" ] && [ "$force" -eq 0 ]; then
    echo "error: $existing already exists (pass --force to overwrite)" >&2; exit 1
  fi
done

# --- url: absolute http(s); hyd.ai posts are directories, the blog 301s the slash-less form
if ! [[ $url =~ ^https?://[^[:space:]\"]+$ ]]; then
  echo "error: redirect_to must be an absolute http(s) URL, got '$url'" >&2; exit 1
fi
if [[ $url =~ ^https://hyd\.ai/[^?#]+$ ]] && [[ $url != */ ]] && [[ ${url##*/} != *.* ]]; then
  url="$url/"; echo "note: hyd.ai post, trailing slash added -> $url"
fi
if probe=$(curl -sS -o /dev/null --max-time 8 -w '%{http_code} %{redirect_url}' "$url" 2>/dev/null); then
  code=${probe%% *}; loc=${probe#* }
  case $code in
    200) echo "ok: target answers 200" ;;
    30[1278]) echo "warning: target answers $code -> $loc (use the final URL unless the redirect is intended)" ;;
    000) echo "note: target not reachable from here, check skipped" ;;
    *) echo "warning: target answers HTTP $code" ;;
  esac
else
  echo "note: target check skipped (no network)"
fi

# --- write the entry (same shape as _redirects/template.md)
title=${title:-$slug}
description=${description:-$title}
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
printf -- '---\ntitle: "%s"\ndescription: "%s"\nredirect_to: "%s"\n---\n' \
  "$(esc "$title")" "$(esc "$description")" "$(esc "$url")" > "_redirects/$slug.md"
echo "wrote _redirects/$slug.md:"; sed 's/^/  /' "_redirects/$slug.md"

# --- verify: validator, then a strict build with the Ruby named in .ruby-version
.github/scripts/validate-redirects.sh
ver=$(cat .ruby-version 2>/dev/null || echo "")
if ! bundle check >/dev/null 2>&1; then
  for d in "$HOME/.rubies/ruby-$ver/bin" "$HOME/.rbenv/versions/$ver/bin" \
           "$HOME/.asdf/installs/ruby/$ver/bin" "$HOME/.local/share/mise/installs/ruby/$ver/bin"; do
    if [ -x "$d/bundle" ] && PATH="$d:$PATH" bundle check >/dev/null 2>&1; then
      export PATH="$d:$PATH"; echo "note: using Ruby from $d"; break
    fi
  done
fi
if ! bundle check >/dev/null 2>&1; then
  echo "error: no Ruby $ver with this Gemfile's gems found; install it (ruby-install/chruby, rbenv, asdf or mise) and run 'bundle install'" >&2
  exit 1
fi
bundle exec jekyll build --strict_front_matter >/dev/null
test -f "_site/$slug/index.html" && echo "ok: strict build produced _site/$slug/index.html"

echo
echo "next: git add _redirects/$slug.md && git commit -s -m 'feat: add $slug short link'"
echo "link after deploy: https://url.hyd.ai/$slug/"
