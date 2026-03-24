# Project Brief: Static Archive Pipeline for NuclearPyramid.com

## User Story

As the maintainer of a dead-site archive, I want a reproducible Ruby-based pipeline that retrieves NuclearPyramid.com content from the Internet Archive, transforms it into a clean static site, and publishes it via GitHub Pages from `docs/` — preserving original `.php` file extensions for link correctness.

## Requirements

### Retrieval (`rake retrieve`)
- Bulk download via `wayback_machine_downloader_straw` gem into `archive.org/`
- Targeted fetch of specific Wayback Machine snapshots (via Net::HTTP with `id_` URLs) for pages the bulk downloader can't retrieve:
  - `great_pyramid.php` from snapshot `20160305172515`
  - `other_two_pyramids.php` from snapshot `20160322015445`
  - `proton.php` from snapshot `20160324003324`
  - `greatpyramid/fig001.gif` from snapshot `20160305172515`

### Transformation (`rake transform`)
- Copy only files in the defined manifest from `archive.org/` into `docs/`
- **Rewrite links**: `http://nuclearpyramid.com` → `https://nuclearpyramid.com` (also www. and :80 variants)
- **Add About page**: `about.php` with placeholder content, matching the site's existing visual style
- **Add nav item**: Insert "About" link into the navigation bar on all content pages
- **Add `.nojekyll`** to `docs/`

### Hosting
- GitHub Pages serving from `docs/` on `main` branch
- No CI workflow — just GH Pages repo settings
- Custom domain: `nuclearpyramid.com`

### Pipeline Tool
- `Gemfile` with `wayback_machine_downloader_straw`, `rake`, `minitest`
- `Rakefile` with tasks: `retrieve`, `retrieve:targeted`, `transform`, `build`, `clean`, `test`

### Scope Exclusions (per user direction)
- No forum archive (`proton_forum/`)
- No HTML book version (`book.htm`, `book_files/`)
- No junk/ad/tracking files
- `energy_solution.php` included despite being commented out in index nav (it's real content with working images)

## Content Manifest

See `memory-bank/active/tasks.md` → "Site File Manifest" for the authoritative, pinned file list.
