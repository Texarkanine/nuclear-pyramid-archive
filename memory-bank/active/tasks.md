# Task: Manifest-Based Targeted Crawl

* Task ID: manifest-targeted-crawl
* Complexity: Level 2
* Type: Simple enhancement

Update `TARGETED_SNAPSHOTS` in `lib/retrieve.rb` to use verified per-page Wayback Machine timestamps for the four real pages, replacing the incorrect uniform timestamp. Remove the image entry (images are covered by bulk download). Add the homepage (`index.php`) which was previously absent from targeted fetches.

## Test Plan (TDD)

### Behaviors to Verify

- B1: `TARGETED_SNAPSHOTS` contains exactly 4 entries (one per real page)
- B2: `TARGETED_SNAPSHOTS` keys are `index.php`, `great_pyramid.php`, `other_two_pyramids.php`, `proton.php`
- B3: Each entry uses its correct per-page timestamp (`20170509195054`, `20170513025806`, `20170420190729`, `20171010225935`)
- B4: All timestamps remain in the 2017 era (existing behavior, regression guard)
- B5: No image/asset entries (`.gif`, `.jpg`, `.png`) in `TARGETED_SNAPSHOTS`
- B6: `other_two_pyramids.php` URL uses `www.nuclearpyramid.com` (preserves archive.org's capture URL)
- B7: `index.php` URL maps to root path `http://nuclearpyramid.com/` (not `index.php`)
- B8: `wayback_id_url` still produces correct `id_` URLs (existing behavior, regression)

### Test Infrastructure

- Framework: Minitest
- Test location: `test/retrieve_test.rb`
- Conventions: `*_test.rb`, `class <Name>Test < Minitest::Test`, `def test_*`
- New test files: none

### Test Mapping

- `RetrieveConstantsTest`:
  - Modify: `test_targeted_snapshots_use_2017_era_timestamps` (exists, should still pass)
  - Add: `test_targeted_snapshots_contains_exactly_four_pages` (B1, B2)
  - Add: `test_targeted_snapshots_use_correct_per_page_timestamps` (B3)
  - Add: `test_targeted_snapshots_excludes_image_assets` (B5)
  - Add: `test_targeted_snapshots_preserves_original_urls` (B6, B7)
- `RetrieveUrlTest`:
  - Keep: `test_wayback_id_url_produces_raw_content_url` (B8, unchanged)

## Implementation Plan

1. **Stub new tests** in `test/retrieve_test.rb` — empty test methods for B1-B7
2. **Implement tests** — fill out assertions for all new test methods
3. **Run tests** — new tests should fail (TARGETED_SNAPSHOTS still has old values)
4. **Update `TARGETED_SNAPSHOTS`** in `lib/retrieve.rb` — replace with correct 4-entry manifest
5. **Run tests** — all tests should pass
6. **Update `memory-bank/systemPatterns.md`** — reflect per-page timestamps instead of uniform timestamp

## Technology Validation

No new technology — validation not required.

## Dependencies

- No new dependencies

## Challenges & Mitigations

- **Homepage URL vs. filename**: `index.php` key maps to URL `http://nuclearpyramid.com/` (root, no filename). `fetch_one` uses the key as local path and `:url` for the HTTP fetch — this works correctly as-is.
- **www subdomain variance**: `other_two_pyramids.php` was captured under `www.nuclearpyramid.com`. The Wayback `id_` URL format handles this; the local filename is still just `other_two_pyramids.php`.

## Status

- [x] Initialization complete
- [x] Test planning complete (TDD)
- [x] Implementation plan complete
- [x] Technology validation complete
- [ ] Preflight
- [ ] Build
- [ ] QA
