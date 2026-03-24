# frozen_string_literal: true

require "wayback_machine_downloader"

# The wayback_machine_downloader_straw gem fires CDX API queries with zero
# delay between them.  When --page-requisites finds many assets (e.g. 28
# images on proton.php), this burst triggers Internet Archive's TCP-level
# rate limiting (ECONNREFUSED).  Prepending a small sleep before each CDX
# call spreads the requests out enough to stay under the threshold.
module WaybackRateLimiter
  CDX_QUERY_DELAY = 1.0 # seconds between CDX API calls

  def get_raw_list_from_api(url, page_index, http)
    sleep(CDX_QUERY_DELAY)
    super
  end
end

WaybackMachineDownloader.prepend(WaybackRateLimiter)
