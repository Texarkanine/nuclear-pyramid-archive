# frozen_string_literal: true

require "fileutils"

module Retrieve
  PAGES = [
    { url: "http://nuclearpyramid.com/",                           timestamp: "20170509195054" },
    { url: "http://nuclearpyramid.com/great_pyramid.php",          timestamp: "20170513025806" },
    { url: "http://www.nuclearpyramid.com/other_two_pyramids.php", timestamp: "20170420190729" },
    { url: "http://nuclearpyramid.com/proton.php",                 timestamp: "20171010225935" },
  ].freeze

  def self.download_cmd(page, dest_dir)
    "wayback_machine_downloader #{page[:url]} -e --page-requisites -t #{page[:timestamp]} -d #{dest_dir}"
  end

  def self.download_all(dest_dir)
    FileUtils.mkdir_p(dest_dir)
    PAGES.each do |page|
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

    Dir.glob(File.join(dest_dir, "http%3A*")).each { |d| FileUtils.rm_rf(d) }
  end
end
