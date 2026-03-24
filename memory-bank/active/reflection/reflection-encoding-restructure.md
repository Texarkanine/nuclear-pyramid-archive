---
task_id: encoding-restructure
date: 2026-03-24
complexity_level: 2
---

# Reflection: Encoding Fix + docs/site Restructure

## Summary

Fixed charset mojibake by rewriting `charset=iso-8859-1` to `charset=utf-8` after transcoding, and restructured output so archive content goes to `docs/site/` with a redirect `docs/index.html` at the docs root. All 5 requirements met, 46 tests passing, QA clean on first pass.

## Requirements vs Outcome

All 5 requirements delivered as specified. No gaps, no additions, no descoping.

## Plan Accuracy

The 5-step plan executed in exact order without reordering or splitting. Preflight caught 3 real issues before build: charset regex case-sensitivity (the archive uses mixed case), an unnecessary step (src/index.html doesn't need changing), and a missing charset in the test fixture. All were addressed during preflight, making the build phase frictionless.

## Build & QA Observations

Build was clean — all steps passed on first try. QA found nothing substantive. The separation of `write_scaffolding` from `build` was a natural decomposition that fell out cleanly.

## Insights

### Technical

The encoding bug is a general pattern: when a pipeline transcodes file content to a different encoding, it must also update any in-band encoding declarations (HTML charset, XML encoding, BOM markers). The original code handled the byte-level transcoding correctly (Windows-1252 → UTF-8) but missed the declaration layer. Worth watching for in any future archiving or file-processing pipeline.

### Process

Nothing notable — plan accuracy was high, likely because the scope was well-bounded (single module + Rakefile).

### Million-Dollar Question

If docs/site/ and proper charset handling had been foundational from the start, `Transform.build` would never have created `.nojekyll` (deployment scaffolding mixed into content assembly), and `rewrite_charset` would have been part of the original encoding conversion block rather than a separate pipeline step. The current architecture is close to that ideal — the `.nojekyll` extraction was a minor refactor, and `rewrite_charset` sits naturally alongside `rewrite_links`. No sweeping redesign warranted.
