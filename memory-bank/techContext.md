# Tech Context

Static HTML archive site, published to GitHub Pages directly from a directory in the repo (no static site generator).

## Source Retrieval

Content is downloaded from the Internet Archive using the `wayback_machine_downloader_straw` Ruby gem (v2.4.6). Install: `gem install wayback_machine_downloader_straw`. Usage: `wayback_machine_downloader http://nuclearpyramid.com -d archive.org --from 20191113203020 -c 8`.

## Build Tools

None yet. A transformation pipeline will be needed to process `archive.org/` (raw source) into a publish-ready directory.

## Hosting

GitHub Pages, serving static files directly from a directory in the repo (no Jekyll, no build step in CI). `.php` extensions are preserved; GitHub Pages will serve them as static files.

## Testing Process

Manual browser verification of the published site.
