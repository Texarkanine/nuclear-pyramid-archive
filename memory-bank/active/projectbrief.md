# Project Brief: Fix Wayback Machine Download Timestamps

## User Story

Fix the retrieval pipeline so that archived pages (`great_pyramid.php`, `other_two_pyramids.php`, `proton.php`) are downloaded from a known-good Wayback Machine snapshot date instead of error/squatter pages.

## Requirements

1. The `wayback_machine_downloader_straw` bulk download must be capped to a known-good date range using `--to`
2. The `TARGETED_SNAPSHOTS` timestamps must point to the 2017-05-13 snapshot that serves actual content
3. Current 2016 timestamps return error pages (domain was squatted by that point)

## Known-Good Timestamp

`20170513025806` — confirmed by user to serve the real content for `great_pyramid.php` (and by extension the other pages from that era).
