# Active Context

## Current Task
Encoding Fix + docs/site Restructure

## Phase
BUILD - COMPLETE

## What Was Done
- Step 1: Added `rewrite_charset` method with 5 tests (iso-8859-1, windows-1252, case-insensitive, utf-8 no-op, no-declaration no-op)
- Step 2: Wired charset rewrite into build pipeline; added charset to test fixture; added build integration test
- Step 3: Extracted `.nojekyll` from build into `write_scaffolding`; added 2 scaffolding tests; flipped build test to assert no .nojekyll
- Step 4: Updated Rakefile: DEST_DIR→DOCS_DIR+SITE_DIR, transform builds to docs/site/ then writes scaffolding to docs/
- Step 5: Updated README with docs/site/ structure, charset rewrite mention, updated file manifest table

## Files Modified
- `lib/transform.rb` — added rewrite_charset, write_scaffolding; removed .nojekyll from build; wired charset rewrite into pipeline
- `Rakefile` — DOCS_DIR/SITE_DIR constants; transform task outputs to site/ and writes scaffolding
- `test/transform_test.rb` — 7 new tests (CharsetRewriteTest: 5, ScaffoldingTest: 2); flipped nojekyll test
- `test/fixtures/archive.org/index.php` — added charset=iso-8859-1 to head for integration test
- `README.md` — updated directory structure, file manifest, test description

## Deviations from Plan
None - built to plan.

## Next Step
QA phase
