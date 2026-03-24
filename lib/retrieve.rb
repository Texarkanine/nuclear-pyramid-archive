# frozen_string_literal: true

require "net/http"
require "uri"
require "fileutils"

module Retrieve
  WAYBACK_ID_BASE = "https://web.archive.org/web/%sid_/%s"

  TARGETED_SNAPSHOTS = {
    "index.php"              => { timestamp: "20170509195054", url: "http://nuclearpyramid.com/" },
    "great_pyramid.php"      => { timestamp: "20170513025806", url: "http://nuclearpyramid.com/great_pyramid.php" },
    "other_two_pyramids.php" => { timestamp: "20170420190729", url: "http://www.nuclearpyramid.com/other_two_pyramids.php" },
    "proton.php"             => { timestamp: "20171010225935", url: "http://nuclearpyramid.com/proton.php" },
  }.freeze

  BULK_DOWNLOAD_CMD = "wayback_machine_downloader http://nuclearpyramid.com -d %s -c 8 --to 20170513"

  def self.wayback_id_url(timestamp, original_url)
    format(WAYBACK_ID_BASE, timestamp, original_url)
  end

  def self.fetch_one(dest_dir, relative_path, snapshot)
    url = wayback_id_url(snapshot[:timestamp], snapshot[:url])
    uri = URI.parse(url)

    dest = File.join(dest_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(dest))

    puts "Fetching #{relative_path} from #{url}..."

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 15, read_timeout: 30) do |http|
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "nuclear-pyramid-archive/1.0 (static site archiver)"
      http.request(request)
    end

    case response
    when Net::HTTPSuccess
      File.binwrite(dest, response.body)
      puts "  -> Saved #{relative_path} (#{response.body.length} bytes)"
    when Net::HTTPRedirection
      warn "  -> REDIRECT for #{relative_path}: #{response["location"]}"
    else
      warn "  -> FAILED #{relative_path}: HTTP #{response.code}"
    end
  end

  def self.fetch_targeted(dest_dir)
    TARGETED_SNAPSHOTS.each do |relative_path, snapshot|
      fetch_one(dest_dir, relative_path, snapshot)
    end
  end

  def self.bulk_download(dest_dir)
    cmd = format(BULK_DOWNLOAD_CMD, dest_dir)
    puts "Running: #{cmd}"
    system(cmd) || warn("Bulk download exited with non-zero status")
  end
end
