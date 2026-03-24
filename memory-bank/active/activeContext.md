# Active Context

## Current Task
Fix Wayback Machine Download Timestamps

## Phase
BUILD - IN-PROGRESS

## What Was Done
- Complexity analysis: Level 1 (single-component bug fix in lib/retrieve.rb)
- Root cause: TARGETED_SNAPSHOTS use 2016 timestamps that return error/squatter pages
- Confirmed fix: use 20170513025806 timestamp; add --to flag to bulk download

## Next Step
- Write failing test, apply fix, verify
