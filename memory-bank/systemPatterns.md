# System Patterns

## How This System Works

This is a static archive of a dead website (nuclearpyramid.com). The source material was retrieved from the Internet Archive using `wayback_machine_downloader_straw` into `archive.org/`. A build/transform pipeline will process these source files into a publishable static site.

The original site was PHP-based, but never used server-side logic in its content pages — the `.php` files are plain HTML. Some downloaded snapshots contain domain-parking spam (ad injection, redirect scripts) rather than genuine content; these must be identified and excluded or replaced.

## Source vs. Publishable Content

`archive.org/` is the raw download directory from the Wayback Machine. Not all files are genuine content — several are domain-parker pages (e.g., `great_pyramid.php`, `other_two_pyramids.php` contain redirect/ad scripts instead of real articles). Only `index.php` contains authentic site content in the current download set.

## Junk File Identification

Files matching patterns in `robots.txt` (`cpx.php`, `medios1.php`, `toolbar.php`, `check_image.php`) plus `check_popunder.php` are ad/tracking infrastructure from the original hosting provider and should be excluded from the published site. Similarly, `index.html`, `gr=/index.html`, and `__qdcc6fb03fbe5/index.html` are domain-parker redirect pages.
