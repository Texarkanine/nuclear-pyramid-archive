# Project Brief: Static Archive Pipeline for NuclearPyramid.com

## User Story

As the maintainer of a dead-site archive, I want a reproducible Ruby-based pipeline that retrieves NuclearPyramid.com content from the Internet Archive, transforms it into a clean static site, and publishes it via GitHub Pages from `docs/` — preserving original `.php` file extensions for link correctness.

## Requirements

### Retrieval (`rake retrieve`)
- Bulk download via `wayback_machine_downloader_straw` gem into `archive.org/`
- Targeted fetch of specific Wayback Machine snapshots (via `curl` with `id_` URLs) for pages the bulk downloader can't retrieve:
  - `great_pyramid.php` from `20160305172515`
  - `other_two_pyramids.php` from `20160322015445`
  - (possibly `proton.php` if a working snapshot is found)

### Transformation (`rake transform`)
- Copy genuine content from `archive.org/` into `docs/`
- **Exclude junk files**: domain-parker pages, ad/tracking infrastructure (`toolbar.php`, `cpx.php`, `medios1.php`, `check_image.php`, `js/general.js`, `robots.txt`, `index.html`, `gr=/`, `__qdcc6fb03fbe5/`, fake `greatpyramid/fig001.gif`)
- **Rewrite links**: `http://nuclearpyramid.com` → `https://nuclearpyramid.com` (and `http://www.nuclearpyramid.com` → same)
- **Remove `index.html`**: `index.php` is the real homepage
- **Add About page**: `about.php` with placeholder content ("This page is a live archive of the original site. TODO: flesh out."), matching the site's existing visual style
- **Add nav item**: Insert "About" link into the navigation bar on all pages
- **Add `.nojekyll`** to `docs/` so GitHub Pages serves `.php` files as static content
- **Add `CNAME`** with `nuclearpyramid.com` if custom domain is configured

### Hosting
- GitHub Pages serving from `docs/` on `main` branch
- No CI workflow needed — just configure GH Pages in repo settings
- `.php` files served as static HTML (enabled by `.nojekyll`)

### Pipeline Tool
- `Gemfile` with `wayback_machine_downloader_straw` gem
- `Rakefile` with tasks: `retrieve`, `retrieve:manual`, `transform`, `build` (full pipeline), `clean`

## Content Inventory

### Genuine content pages
- `index.php` — Homepage (in archive.org/)
- `energy_solution.php` — "Solution to Our Energy Problem" (in archive.org/)
- `book.htm` — "From Gravitons to Galaxies" HTML book (in archive.org/)
- `great_pyramid.php` — "Great Pyramid at Giza" (needs targeted fetch from Wayback)
- `other_two_pyramids.php` — "The Other Two Pyramids" (needs targeted fetch from Wayback)
- `proton.php` — "Pyramidal Proton Model" (needs earlier snapshot, status TBD)

### Genuine assets (all in archive.org/)
- Root figures: `fig001.jpg`–`fig028.jpg`, `fig003.gif`, `fig005.gif`, `np_logo.gif`, `nuclides.gif`
- Pyramid figures: `greatpyramid/fig002.gif`, `greatpyramid/fig003.gif`
- Energy figures: `energy/1.png`, `energy/2.gif`–`energy/7.gif`
- Book figures: `book_files/image*.{jpg,gif}`
- Book download: `From Gravitons to Galaxies.docx`

### Forum archive (proton_forum/)
- ~20 phpBB HTML snapshots — read-only, non-functional (no DB). Include as-is.

## Constraints
- Original `.php` file extensions must be preserved
- The `nuclearpyramid.com` domain stays in all references, rewritten from http to https
- `archive.org/` is the raw source directory; `docs/` is the publish target
