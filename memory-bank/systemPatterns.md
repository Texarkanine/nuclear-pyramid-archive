# System Patterns

## How This System Works

This is a static archive of a dead website (nuclearpyramid.com). The source material was retrieved from the Internet Archive using `wayback_machine_downloader_straw` into `archive.org/`. A build/transform pipeline will process these source files into a publishable static site.

The original site was PHP-based, but never used server-side logic in its content pages — the `.php` files are plain HTML. Some downloaded snapshots contain domain-parking spam (ad injection, redirect scripts) rather than genuine content; these must be identified and excluded or replaced.

## Source vs. Publishable Content

`archive.org/` is the raw download directory from the Wayback Machine. Not all files in the latest Wayback snapshots are genuine content — the domain was squatted after the site went offline, so recent captures contain redirect/ad scripts. The retrieval pipeline uses `--to 20170513` to cap bulk downloads at a known-good era, and `TARGETED_SNAPSHOTS` in `lib/retrieve.rb` pins each of the four real pages to its own verified-good Wayback snapshot timestamp. The targeted fetch runs after the bulk download, overwriting any bad captures with known-good content.

## Junk File Identification

Files matching patterns in `robots.txt` (`cpx.php`, `medios1.php`, `toolbar.php`, `check_image.php`) plus `check_popunder.php` are ad/tracking infrastructure from the original hosting provider and should be excluded from the published site. Similarly, `index.html`, `gr=/index.html`, and `__qdcc6fb03fbe5/index.html` are domain-parker redirect pages.
