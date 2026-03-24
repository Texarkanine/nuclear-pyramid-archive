# Project Brief: Encoding Fix + docs/site Restructure

## User Story

Two issues with the archive pipeline:

### 1. Encoding Mojibake

`docs/index.php` line 78 renders `â€œunlimitedâ€` instead of `"unlimited"`. The transform transcodes Windows-1252 smart quotes (0x93/0x94) to UTF-8 (`\xe2\x80\x9c`/`\xe2\x80\x9d`), but the HTML meta tag still declares `charset=iso-8859-1`. Browser interprets UTF-8 bytes as ISO-8859-1, producing mojibake.

### 2. Directory Restructure

All archive content should go into `docs/site/`, not directly into `docs/`. A dummy `docs/index.html` should redirect visitors to `site/index.php`. This keeps the GitHub Pages root clean and allows the redirect page to serve as a landing entry point.

## Requirements

1. When transcoding to UTF-8, update the HTML `charset` meta declaration to match (`charset=utf-8`)
2. Transform output goes to `docs/site/` instead of `docs/`
3. `docs/index.html` is a generated redirect to `site/index.php`
4. `docs/.nojekyll` remains at the docs root (not inside `site/`)
5. Existing tests must be updated — no regressions
