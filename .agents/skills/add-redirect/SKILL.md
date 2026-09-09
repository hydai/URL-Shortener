---
name: add-redirect
description: Use when asked to add, create or register a new short link, redirect entry or 短網址 in this URL shortener repo (a new file under _redirects/), including requests like "幫我加一個短網址" or "make url.hyd.ai/xxx point to ..."
---

# Add a short link

One file `_redirects/<slug>.md` becomes `https://url.hyd.ai/<slug>/`. The script writes and verifies the file; you choose the slug and the wording, then commit.

## Steps

1. **Decide the four fields.**
   - `slug`: lowercase ASCII letters, digits, single hyphens. Join an event name and year without a separator (`coscup2026`, `gosimparis2025`); use hyphens only between real words (`wasm-container-20231201`). GitHub Pages is case-sensitive, so never uppercase.
   - `url`: exactly the absolute URL the user gave. Posts on hyd.ai are directories and need a trailing slash; the script adds it.
   - `title`: the human-readable name the user used (`SITCON 2026`). Falls back to the slug.
   - `description`: one line for the share preview, in the user's language (`SITCON 2026 演講講稿`). Use the user's wording verbatim when they gave one.
2. **Run the script from the repo root.** Never edit `_redirects/template.md`; it is the copy source and is excluded from the site.
   ```bash
   .agents/skills/add-redirect/add-redirect.sh <slug> "<url>" --title "<title>" --description "<description>"
   ```
   It validates slug and URL, writes the file, runs `.github/scripts/validate-redirects.sh` and a strict Jekyll build with the Ruby named in `.ruby-version` (it finds chruby, rbenv, asdf and mise installs by itself). A non-zero exit means the entry is not ready: fix what it reports. Do not skip the build and do not hand-write the file instead.
3. **Commit the one file** with the command the script prints:
   ```bash
   git add _redirects/<slug>.md && git commit -s -m "feat: add <slug> short link"
   ```
   Conventional Commits plus `Signed-off-by`, like every commit in this repo.
4. **Push only if the user asked to deploy** (上線, push, deploy). Pushing `main` is the production deploy:
   ```bash
   git push origin main
   gh run watch "$(gh run list -w 'Deploy Jekyll site to Pages' -L 1 --json databaseId --jq '.[0].databaseId')" --exit-status
   curl -sI "https://url.hyd.ai/<slug>/" | head -1   # expect HTTP/2 200
   ```
   Otherwise stop after the commit.

## Report back

Slug, the final link, the title and description you used, and whether it is committed or deployed.

## Common mistakes

| Mistake | Why it matters |
|---|---|
| `https://hyd.ai/Some-Post` without the trailing slash | The blog answers 301, every visitor pays an extra hop |
| Skipping the build because `bundle` fails on the system Ruby | Wrong Ruby on PATH; the script switches to `.ruby-version` for you |
| Leaving the new file uncommitted | The user expects one commit per link |
| Pushing without being asked | Push is the production deploy |
| Uppercase or spaces in the slug | 404 on GitHub Pages or an invalid URL |
