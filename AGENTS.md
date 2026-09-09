# URL-Shortener: notes for agents

Jekyll site deployed to https://url.hyd.ai by GitHub Actions on every push to `main`. Each file in `_redirects/` is one short link: `_redirects/<slug>.md` becomes `https://url.hyd.ai/<slug>/`.

- To add a short link, use the `add-redirect` skill in `.agents/skills/add-redirect/SKILL.md`. Its script writes and verifies the entry; do not hand-write the file.
- Slugs are lowercase ASCII. Targets on hyd.ai need a trailing slash. `_redirects/template.md` is the copy source and is never published.
- Verify with `.github/scripts/validate-redirects.sh` and `bundle exec jekyll build --strict_front_matter`, using the Ruby named in `.ruby-version`.
- Commit each new entry: Conventional Commits with `Signed-off-by` (`git commit -s`). Never push unless the user asks to deploy; pushing `main` deploys.
