# Project Brief: Manifest-Based Targeted Crawl

## User Story

Replace the hardcoded `TARGETED_SNAPSHOTS` in `lib/retrieve.rb` with correct per-page Wayback Machine timestamps sourced from a verified manifest of four known-good pages.

## Requirements

1. Update `TARGETED_SNAPSHOTS` to use the correct per-page timestamps for the four real pages:
   - `index.php` → timestamp `20170509195054`, URL `http://nuclearpyramid.com/`
   - `great_pyramid.php` → timestamp `20170513025806`, URL `http://nuclearpyramid.com/great_pyramid.php`
   - `other_two_pyramids.php` → timestamp `20170420190729`, URL `http://www.nuclearpyramid.com/other_two_pyramids.php`
   - `proton.php` → timestamp `20171010225935`, URL `http://nuclearpyramid.com/proton.php`
2. Remove the `greatpyramid/fig001.gif` entry (images are already covered by bulk download)
3. Keep bulk crawl unchanged — it provides images/assets
4. Targeted fetch continues to run after bulk download, overwriting bad page content
5. Do NOT add image-fetching logic to targeted path (skip for now)

## Constraints

- Existing pipeline structure (`rake retrieve` → `rake retrieve:targeted` → `rake transform`) stays the same
- `Rakefile` should not need changes
- Transform manifest and transform logic are unaffected
