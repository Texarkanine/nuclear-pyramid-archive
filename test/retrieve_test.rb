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
end

class RetrieveUrlTest < Minitest::Test
  def test_wayback_id_url_produces_raw_content_url
    url = Retrieve.wayback_id_url("20170513025806", "http://nuclearpyramid.com/great_pyramid.php")
    assert_equal "https://web.archive.org/web/20170513025806id_/http://nuclearpyramid.com/great_pyramid.php", url
  end
end
