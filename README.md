# NuclearPyramid.com Archive

A static archive of the original [NuclearPyramid.com](https://nuclearpyramid.com) website, preserved from the Internet Archive. I bought the abandoned domain and am hosting this archive on the original domain.

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
rake build        # Full pipeline: retrieve + transform
rake clean        # Remove docs/ output directory
rake clean_fetch  # Remove archive.org/ output directory
rake retrieve     # Download pages + images from Wayback Machine into archive.org/
rake transform    # Transform archive.org/ into docs/site/ for publishing
```

## How It Works

1. **Retrieve**: Downloads four specific pages from the Wayback Machine using `wayback_machine_downloader` with `--exact-url --page-requisites`. Each page is pinned to a known-good 2017-era snapshot timestamp. Page requisites (images) are automatically downloaded alongside each page.

2. **Transform**: Copies all downloaded files from `archive.org/` to `docs/site/`, applying HTML transforms to `.php`/`.html` files: rewrites `http://nuclearpyramid.com` links to `https://`, rewrites `charset=iso-8859-1` to `charset=utf-8`, rewrites the "From Gravitons to Galaxies" docx download link to point to a [GitHub Release](https://github.com/Texarkanine/nuclear-pyramid-archive/releases) asset (bypassing the nginx proxy for the 13MB file), and injects an "About" navigation link. Custom pages from `src/` are copied on top.
