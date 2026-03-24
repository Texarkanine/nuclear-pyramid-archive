# NuclearPyramid.com Archive

A static archive of the original [NuclearPyramid.com](https://nuclearpyramid.com) website, preserved from the Internet Archive and hosted on GitHub Pages.

## Setup

```bash
bundle install
```

## Usage

**Full pipeline** (retrieve from Wayback Machine + transform):

```bash
bundle exec rake build
```

**Individual steps:**

```bash
bundle exec rake retrieve   # Download 4 pages + images from Wayback Machine
bundle exec rake transform  # Rewrite links, inject nav, copy src/ → docs/site/
bundle exec rake clean      # Remove docs/ output
bundle exec rake test        # Run test suite
```

## How It Works

1. **Retrieve**: Downloads four specific pages from the Wayback Machine using `wayback_machine_downloader` with `--exact-url --page-requisites`. Each page is pinned to a known-good 2017-era snapshot timestamp. Page requisites (images) are automatically downloaded alongside each page. Post-download cleanup renames `index.html` → `index.php` and removes URL-encoded duplicate directories.

2. **Transform**: Copies all downloaded files from `archive.org/` to `docs/site/`, applying HTML transforms to `.php`/`.html` files: rewrites `http://nuclearpyramid.com` links to `https://`, rewrites `charset=iso-8859-1` to `charset=utf-8`, and injects an "About" navigation link. Custom pages from `src/` are copied on top.

3. **Publish**: GitHub Pages serves `docs/` as a static site. `docs/index.html` redirects to `site/index.php`. A `.nojekyll` file disables Jekyll processing so `.php` files are served as-is.

## Pages Manifest

| Page | Wayback Timestamp | URL |
|---|---|---|
| Home | 20170509195054 | `http://nuclearpyramid.com/` |
| Great Pyramid | 20170513025806 | `http://nuclearpyramid.com/great_pyramid.php` |
| Other Two Pyramids | 20170420190729 | `http://www.nuclearpyramid.com/other_two_pyramids.php` |
| Proton | 20171010225935 | `http://nuclearpyramid.com/proton.php` |

## GitHub Pages Configuration

1. Go to **Settings > Pages** in the repository
2. Set **Source** to "Deploy from a branch"
3. Set **Branch** to `main`, folder to `/docs`
4. Optionally configure the custom domain `nuclearpyramid.com`

## Testing

```bash
bundle exec rake test
```

Tests cover the page manifest, download command generation, post-download cleanup, charset rewriting, link rewriting, navigation injection, scaffolding generation, and full build integration.
