# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/retrieve"

class RetrieveConstantsTest < Minitest::Test
  def test_bulk_download_cmd_caps_snapshot_date
    assert_match(/--to\s+\d{8,14}/, Retrieve::BULK_DOWNLOAD_CMD,
      "BULK_DOWNLOAD_CMD must include a --to timestamp to avoid downloading squatter-era snapshots")
  end

  def test_targeted_snapshots_use_2017_era_timestamps
    Retrieve::TARGETED_SNAPSHOTS.each do |path, snapshot|
      assert_match(/^2017/, snapshot[:timestamp],
        "#{path} should use a 2017 timestamp (known-good era), got #{snapshot[:timestamp]}")
    end
  end

  EXPECTED_PAGES = %w[
    index.php
    great_pyramid.php
    other_two_pyramids.php
    proton.php
  ].freeze

  EXPECTED_TIMESTAMPS = {
    "index.php"              => "20170509195054",
    "great_pyramid.php"      => "20170513025806",
    "other_two_pyramids.php" => "20170420190729",
    "proton.php"             => "20171010225935",
  }.freeze

  def test_targeted_snapshots_contains_exactly_four_pages
    assert_equal EXPECTED_PAGES.sort, Retrieve::TARGETED_SNAPSHOTS.keys.sort
  end

  def test_targeted_snapshots_use_correct_per_page_timestamps
    EXPECTED_TIMESTAMPS.each do |page, expected_ts|
      actual_ts = Retrieve::TARGETED_SNAPSHOTS.dig(page, :timestamp)
      assert_equal expected_ts, actual_ts,
        "#{page} should use timestamp #{expected_ts}, got #{actual_ts}"
    end
  end

  def test_targeted_snapshots_excludes_image_assets
    Retrieve::TARGETED_SNAPSHOTS.each_key do |path|
      refute_match(/\.(gif|jpg|jpeg|png)\z/i, path,
        "TARGETED_SNAPSHOTS should not contain image assets, found #{path}")
    end
  end

  def test_targeted_snapshots_preserves_original_urls
    assert_equal "http://nuclearpyramid.com/",
      Retrieve::TARGETED_SNAPSHOTS.dig("index.php", :url),
      "index.php should map to root URL (no index.php in path)"

    assert_match %r{www\.nuclearpyramid\.com},
      Retrieve::TARGETED_SNAPSHOTS.dig("other_two_pyramids.php", :url),
      "other_two_pyramids.php should preserve the www subdomain from archive.org"
  end
end

class RetrieveUrlTest < Minitest::Test
  def test_wayback_id_url_produces_raw_content_url
    url = Retrieve.wayback_id_url("20170513025806", "http://nuclearpyramid.com/great_pyramid.php")
    assert_equal "https://web.archive.org/web/20170513025806id_/http://nuclearpyramid.com/great_pyramid.php", url
  end
end
