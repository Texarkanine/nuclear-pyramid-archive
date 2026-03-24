# frozen_string_literal: true

require_relative "test_helper"

class RetrievePagesConstantTest < Minitest::Test
  def test_page_count
    assert_equal 5, Retrieve::PAGES.length
  end

  def test_snapshot_cutoff_is_before_2018
    assert_operator Retrieve::SNAPSHOT_CUTOFF, :<=, "20180101000000",
      "SNAPSHOT_CUTOFF must not extend into the squatter era"
  end

  def test_all_timestamps_are_before_cutoff
    Retrieve::PAGES.each do |page|
      assert_operator page[:timestamp], :<, Retrieve::SNAPSHOT_CUTOFF,
        "#{page[:url]} timestamp #{page[:timestamp]} must be before SNAPSHOT_CUTOFF #{Retrieve::SNAPSHOT_CUTOFF}"
    end
  end

  def test_includes_index_page
    urls = Retrieve::PAGES.map { |p| p[:url] }
    assert_includes urls, "http://nuclearpyramid.com/"
  end

  def test_includes_great_pyramid
    urls = Retrieve::PAGES.map { |p| p[:url] }
    assert_includes urls, "http://nuclearpyramid.com/great_pyramid.php"
  end

  def test_includes_other_two_pyramids_with_www
    urls = Retrieve::PAGES.map { |p| p[:url] }
    assert_includes urls, "http://www.nuclearpyramid.com/other_two_pyramids.php"
  end

  def test_includes_proton
    urls = Retrieve::PAGES.map { |p| p[:url] }
    assert_includes urls, "http://nuclearpyramid.com/proton.php"
  end
end

class RetrieveDownloadCmdTest < Minitest::Test
  def setup
    @page = { url: "http://nuclearpyramid.com/great_pyramid.php", timestamp: "20170513025806" }
  end

  def test_uses_exact_url_flag
    cmd = Retrieve.download_cmd(@page, "/tmp/test")
    assert_includes cmd, "-e"
  end

  def test_uses_page_requisites_flag
    cmd = Retrieve.download_cmd(@page, "/tmp/test")
    assert_includes cmd, "--page-requisites"
  end

  def test_includes_timestamp
    cmd = Retrieve.download_cmd(@page, "/tmp/test")
    assert_includes cmd, "20170513025806"
  end

  def test_includes_destination_directory
    cmd = Retrieve.download_cmd(@page, "/tmp/test")
    assert_includes cmd, "-d /tmp/test"
  end

  def test_includes_page_url
    cmd = Retrieve.download_cmd(@page, "/tmp/test")
    assert_includes cmd, "http://nuclearpyramid.com/great_pyramid.php"
  end
end

class RetrieveCleanupTest < Minitest::Test
  def setup
    @dir = File.join(FIXTURES_DIR, "cleanup_test")
    FileUtils.rm_rf(@dir)
    FileUtils.mkdir_p(@dir)
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def test_renames_index_html_to_index_php
    File.write(File.join(@dir, "index.html"), "<html>test</html>")
    Retrieve.cleanup(@dir)
    assert File.exist?(File.join(@dir, "index.php"))
    refute File.exist?(File.join(@dir, "index.html"))
  end

  def test_does_not_overwrite_existing_index_php
    File.write(File.join(@dir, "index.html"), "wrong")
    File.write(File.join(@dir, "index.php"), "correct")
    Retrieve.cleanup(@dir)
    assert_equal "correct", File.read(File.join(@dir, "index.php"))
  end

  def test_relocates_files_from_encoded_directories
    encoded = File.join(@dir, "http%3A", "nuclearpyramid.com", "greatpyramid")
    FileUtils.mkdir_p(encoded)
    File.write(File.join(encoded, "fig001.gif"), "GIF8real")
    Retrieve.cleanup(@dir)
    refute Dir.exist?(File.join(@dir, "http%3A")),
      "encoded directory should be removed after relocation"
    assert File.exist?(File.join(@dir, "greatpyramid", "fig001.gif")),
      "file should be relocated to correct relative path"
    assert_equal "GIF8real", File.read(File.join(@dir, "greatpyramid", "fig001.gif"))
  end

  def test_noop_when_no_index_html
    File.write(File.join(@dir, "proton.php"), "<html>test</html>")
    Retrieve.cleanup(@dir)
    refute File.exist?(File.join(@dir, "index.html"))
    refute File.exist?(File.join(@dir, "index.php"))
    assert File.exist?(File.join(@dir, "proton.php"))
  end
end
