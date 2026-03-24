# Tasks: Fix Wayback Machine Download Timestamps

## Bug: Wrong Wayback Machine timestamps in lib/retrieve.rb

**What broke:** `TARGETED_SNAPSHOTS` used 2016 timestamps that returned error/domain-squatter pages. `BULK_DOWNLOAD_CMD` had no `--to` cap, allowing too-new (broken) snapshots.

**Why:** The nuclearpyramid.com domain was squatted sometime between 2017 and the 2016 timestamps. The 2016 snapshots captured the squatter content, while the 2017-05-13 snapshot captured the real site.

**What changed:**
- Updated all `TARGETED_SNAPSHOTS` timestamps from `2016*` to `20170513025806` (known-good snapshot)
- Added `--to 20170513` to `BULK_DOWNLOAD_CMD` to cap bulk downloads at the known-good era
- Added `test/retrieve_test.rb` with 3 tests (constants validation + URL format)

**Files affected:** `lib/retrieve.rb`, `test/retrieve_test.rb` (new)

## Checklist

- [x] Write failing test for Retrieve constants
- [x] Update BULK_DOWNLOAD_CMD with --to flag
- [x] Update TARGETED_SNAPSHOTS timestamps to 20170513025806
- [x] Verify full test suite passes (38 runs, 57 assertions, 0 failures)
