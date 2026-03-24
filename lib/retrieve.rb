# frozen_string_literal: true

require "fileutils"

module Retrieve
  SNAPSHOT_CUTOFF = "20180101000000"

  PAGES = [
    { url: "http://nuclearpyramid.com/",                           timestamp: "20170509195054" },
    { url: "http://nuclearpyramid.com/great_pyramid.php",          timestamp: "20170513025806" },
    { url: "http://www.nuclearpyramid.com/other_two_pyramids.php", timestamp: "20170420190729" },
    { url: "http://nuclearpyramid.com/proton.php",                 timestamp: "20171010225935" },
    { url: "http://nuclearpyramid.com/greatpyramid/fig001.gif",    timestamp: "20170320154414" },
  ].freeze

  def self.download_cmd(page, dest_dir)
    "wayback_machine_downloader #{page[:url]} -e --page-requisites -t #{page[:timestamp]} -d #{dest_dir}"
  end

  def self.download_all(dest_dir)
    FileUtils.mkdir_p(dest_dir)
    PAGES.each_with_index do |page, i|
      if page[:timestamp] >= SNAPSHOT_CUTOFF
        raise "BLOCKED: #{page[:url]} timestamp #{page[:timestamp]} is at or after SNAPSHOT_CUTOFF #{SNAPSHOT_CUTOFF}"
      end
      sleep(5) if i > 0
      cmd = download_cmd(page, dest_dir)
      puts "Running: #{cmd}"
      system(cmd) || warn("Download failed for #{page[:url]}")
    end
    cleanup(dest_dir)
  end

  def self.cleanup(dest_dir)
    html = File.join(dest_dir, "index.html")
    php = File.join(dest_dir, "index.php")
    File.rename(html, php) if File.exist?(html) && !File.exist?(php)

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
