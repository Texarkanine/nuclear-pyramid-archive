---
task_id: encoding-restructure
complexity_level: 2
date: 2026-03-24
status: completed
---

# TASK ARCHIVE: Encoding Fix + docs/site Restructure

## SUMMARY

Fixed HTML charset mojibake by rewriting `charset=iso-8859-1` to `charset=utf-8` after the pipeline transcodes content to UTF-8, so browsers no longer misinterpret UTF-8 bytes. Restructured generated output so archive content lives under `docs/site/`, with a root `docs/index.html` redirect to `site/index.php` and `docs/.nojekyll` kept at the docs root for GitHub Pages.

## REQUIREMENTS

1. When transcoding to UTF-8, update the HTML `charset` meta declaration to match (`charset=utf-8`).
2. Transform output goes to `docs/site/` instead of `docs/`.
3. `docs/index.html` is a generated redirect to `site/index.php`.
4. `docs/.nojekyll` remains at the docs root (not inside `site/`).
5. Existing tests updated — no regressions.

All five requirements were met; 46 tests passing; QA passed on first pass.

## IMPLEMENTATION

- **Transform pipeline (`lib/transform.rb`, etc.):** After byte-level transcoding (e.g. Windows-1252 smart quotes → UTF-8), added logic to align in-band declarations with the actual encoding (charset meta rewrite), analogous to existing link rewriting. Output paths target `docs/site/`; scaffolding such as `.nojekyll` stays at `docs/`.
- **Build / Rake:** Adjusted tasks so generated `docs/index.html` performs the redirect; site PHP/HTML assets land under `docs/site/`.
- **Tests:** Updated expectations for new paths and charset behavior (multiple test classes covering the planned behaviors).

Preflight caught real issues before build: charset regex needed case-insensitivity (mixed-case meta in archives), removal of an unnecessary `src/index.html` step, and a test fixture charset fix.

## TESTING

- Full Ruby test suite: **46 tests, 69 assertions, 0 failures** after build.
- **`/niko-qa`:** PASS — no substantive issues; all five requirements verified.

## LESSONS LEARNED

- **Encoding pipelines:** When transcoding file content to a different encoding, also update any in-band encoding declarations (HTML `charset`, XML encoding, BOM where applicable). Byte-level transcoding alone is insufficient if declarations still claim the old encoding.
- **Scope:** A well-bounded scope (single transform module + Rake integration) kept plan and build aligned; separating `write_scaffolding` from `build` remained a clean decomposition.

## PROCESS IMPROVEMENTS

None called out — plan accuracy was high for this task; no recurring process gaps identified in reflection.

## TECHNICAL IMPROVEMENTS

If `docs/site/` and correct charset handling had been baseline from the start, deployment scaffolding would not have been mixed into content assembly in the same way, and charset rewriting would have lived alongside the original conversion step rather than as a follow-on. Current structure is close to that ideal after this work; no sweeping redesign was warranted.

## NEXT STEPS

None.

---

## Inlined reflection (ephemeral source: `reflection-encoding-restructure.md`)

**Reflection summary:** Fixed charset mojibake via charset meta rewrite after transcoding; restructured output to `docs/site/` with root `docs/index.html` redirect. All requirements met; tests green; QA clean first pass.

**Plan accuracy:** Five-step plan executed in order. Preflight found charset regex case-sensitivity, unnecessary `src/index.html` change, and missing charset in a fixture — all fixed before build.

**Insights:** Same as LESSONS LEARNED / TECHNICAL IMPROVEMENTS above; reflection emphasized watching declaration-layer updates in any future archiving or file-processing pipelines.
