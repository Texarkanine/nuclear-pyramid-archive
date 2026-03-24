# frozen_string_literal: true

require "fileutils"
require_relative "wayback_patch"

module Retrieve
  SNAPSHOT_CUTOFF = "20180825193951"

  PAGES = [
    { url: "http://nuclearpyramid.com/",                           timestamp: "20170509195054" },
    { url: "http://nuclearpyramid.com/great_pyramid.php",          timestamp: "20170513025806" },
    { url: "http://www.nuclearpyramid.com/other_two_pyramids.php", timestamp: "20170420190729" },
    { url: "http://nuclearpyramid.com/proton.php",                 timestamp: "20171010225935" },
    { url: "http://nuclearpyramid.com/greatpyramid/fig001.gif",    timestamp: "20170320154414" },
    { url: "http://nuclearpyramid.com/From%20Gravitons%20to%20Galaxies.docx", timestamp: "20180825193950" }
  ].freeze

  def self.download_all(dest_dir)
    FileUtils.mkdir_p(dest_dir)
    PAGES.each_with_index do |page, i|
      if page[:timestamp] >= SNAPSHOT_CUTOFF
        raise "BLOCKED: #{page[:url]} timestamp #{page[:timestamp]} is at or after SNAPSHOT_CUTOFF #{SNAPSHOT_CUTOFF}"
      end
      sleep(5) if i > 0
      puts "Downloading #{page[:url]} @ #{page[:timestamp]}"
      downloader = WaybackMachineDownloader.new(
        base_url: page[:url],
        exact_url: true,
        page_requisites: true,
        to_timestamp: page[:timestamp],
        directory: dest_dir
      )
      downloader.download_files
    end
    relocate_encoded_dirs(dest_dir)
  end

  def self.relocate_encoded_dirs(dest_dir)
    Dir.glob(File.join(dest_dir, "http%3A*")).each do |encoded_root|
      Dir.glob(File.join(encoded_root, "**", "*")).each do |src|
        next unless File.file?(src)
        relative = src.sub(%r{\A#{Regexp.escape(encoded_root)}/[^/]+/}, "")
        dest = File.join(dest_dir, relative)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.mv(src, dest, force: true)
      end
      FileUtils.rm_rf(encoded_root)
    end
  end
end
