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
bundle exec rake retrieve           # Bulk download from Wayback Machine
bundle exec rake retrieve:targeted  # Fetch specific pages from known-good snapshots
bundle exec rake transform          # Filter, rewrite links, copy src/ pages → docs/
bundle exec rake clean              # Remove docs/ output
bundle exec rake test               # Run test suite
```

The `transform` step reads from `archive.org/` and `src/`, and writes the final static site to `docs/`.

## How It Works

1. **Retrieve**: Downloads the site from the Wayback Machine using `wayback_machine_downloader_straw`. Three core articles (`great_pyramid.php`, `other_two_pyramids.php`, `proton.php`) and one image (`greatpyramid/fig001.gif`) are fetched from specific known-good snapshots via `id_` URLs, since their latest captures were overwritten by domain-parker content.

2. **Transform**: Filters files to a curated manifest (excluding junk, ad infrastructure, and the defunct phpBB forum), rewrites all `http://nuclearpyramid.com` links to `https://`, injects an "About" navigation link, copies custom pages from `src/`, and validates binary files by checking magic bytes.

3. **Publish**: GitHub Pages serves `docs/` as a static site. A `.nojekyll` file disables Jekyll processing so `.php` files are served as-is.

## GitHub Pages Configuration

1. Go to **Settings > Pages** in the repository
2. Set **Source** to "Deploy from a branch"
3. Set **Branch** to `main`, folder to `/docs`
4. Optionally configure the custom domain `nuclearpyramid.com`

## File Manifest

The transform step publishes exactly these files to `docs/`:

| Category | Files |
|---|---|
| Pages | `index.php`, `great_pyramid.php`, `other_two_pyramids.php`, `proton.php`, `energy_solution.php`, `about.php` |
| Proton figures | 26 JPGs (`fig001`–`fig028`, excluding `fig003`/`fig005`) + `fig003.gif`, `fig005.gif`, `nuclides.gif` |
| Pyramid figures | `greatpyramid/fig001.gif`–`fig003.gif` |
| Energy figures | `energy/1.png`, `energy/2.gif`–`energy/7.gif` |
| Other assets | `np_logo.gif`, `From Gravitons to Galaxies.docx` |
| Meta | `.nojekyll` |

## Testing

```bash
bundle exec rake test
```

Tests cover manifest filtering, link rewriting, navigation injection, binary file validation, and full build integration.
