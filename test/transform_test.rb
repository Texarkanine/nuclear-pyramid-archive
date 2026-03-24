# frozen_string_literal: true

require_relative "test_helper"

class CharsetRewriteTest < Minitest::Test
  def test_rewrites_iso_8859_1_to_utf8
    input = '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
    expected = '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
    assert_equal expected, Transform.rewrite_charset(input)
  end

  def test_rewrites_windows_1252_to_utf8
    input = '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
    expected = '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
    assert_equal expected, Transform.rewrite_charset(input)
  end

  def test_case_insensitive_rewrite
    input = '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=ISO-8859-1">'
    expected = '<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=utf-8">'
    assert_equal expected, Transform.rewrite_charset(input)
  end

  def test_leaves_utf8_charset_alone
    input = '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
    assert_equal input, Transform.rewrite_charset(input)
  end

  def test_leaves_html_without_charset_alone
    input = "<html><body>No charset</body></html>"
    assert_equal input, Transform.rewrite_charset(input)
  end
end

class ManifestFilterTest < Minitest::Test
  def test_genuine_page_in_manifest
    assert Transform.in_manifest?("index.php")
  end

  def test_junk_page_not_in_manifest
    refute Transform.in_manifest?("toolbar.php")
  end

  def test_image_in_manifest
    assert Transform.in_manifest?("fig001.jpg")
  end

  def test_forum_not_in_manifest
    refute Transform.in_manifest?("proton_forum/login.php")
  end

  def test_energy_image_in_manifest
    assert Transform.in_manifest?("energy/1.png")
  end

  def test_greatpyramid_image_in_manifest
    assert Transform.in_manifest?("greatpyramid/fig002.gif")
  end

  def test_docx_in_manifest
    assert Transform.in_manifest?("From Gravitons to Galaxies.docx")
  end

  def test_book_htm_not_in_manifest
    refute Transform.in_manifest?("book.htm")
  end

  def test_js_not_in_manifest
    refute Transform.in_manifest?("js/general.js")
  end

  def test_index_html_not_in_manifest
    refute Transform.in_manifest?("index.html")
  end
end

class LinkRewriteTest < Minitest::Test
  def test_rewrites_http_to_https
    input = '<a href="http://nuclearpyramid.com/great_pyramid.php">link</a>'
    expected = '<a href="https://nuclearpyramid.com/great_pyramid.php">link</a>'
    assert_equal expected, Transform.rewrite_links(input)
  end

  def test_rewrites_www_variant
    input = '<a href="http://www.nuclearpyramid.com/foo">link</a>'
    expected = '<a href="https://nuclearpyramid.com/foo">link</a>'
    assert_equal expected, Transform.rewrite_links(input)
  end

  def test_rewrites_port_80_variant
    input = '<a href="http://nuclearpyramid.com:80/proton.php">link</a>'
    expected = '<a href="https://nuclearpyramid.com/proton.php">link</a>'
    assert_equal expected, Transform.rewrite_links(input)
  end

  def test_leaves_unrelated_urls_alone
    input = '<a href="http://example.com/page">link</a>'
    assert_equal input, Transform.rewrite_links(input)
  end

  def test_rewrites_multiple_occurrences
    input = 'http://nuclearpyramid.com/a and http://www.nuclearpyramid.com/b'
    expected = 'https://nuclearpyramid.com/a and https://nuclearpyramid.com/b'
    assert_equal expected, Transform.rewrite_links(input)
  end

  def test_does_not_double_rewrite_https
    input = '<a href="https://nuclearpyramid.com/page">link</a>'
    assert_equal input, Transform.rewrite_links(input)
  end
end

class NavInjectionTest < Minitest::Test
  def test_injects_about_link_into_nav_bar
    html = File.read(File.join(FIXTURE_SOURCE, "index.php"))
    result = Transform.inject_about_nav(html)
    assert_includes result, 'href="./about.php"'
    assert_includes result, "About"
  end

  def test_preserves_existing_nav_items
    html = File.read(File.join(FIXTURE_SOURCE, "index.php"))
    result = Transform.inject_about_nav(html)
    assert_includes result, "Great Pyramid"
    assert_includes result, "2nd &amp; 3rd Pyramids"
  end

  def test_leaves_html_without_nav_unchanged
    html = "<html><body><p>No nav</p></body></html>"
    assert_equal html, Transform.inject_about_nav(html)
  end

  def test_does_not_double_inject
    html = File.read(File.join(FIXTURE_SOURCE, "index.php"))
    result = Transform.inject_about_nav(html)
    result2 = Transform.inject_about_nav(result)
    assert_equal result.scan("about.php").length, result2.scan("about.php").length
  end
end

class BinaryValidationTest < Minitest::Test
  def test_valid_gif_passes
    path = File.join(FIXTURE_SOURCE, "np_logo.gif")
    assert Transform.valid_binary?(path)
  end

  def test_valid_jpeg_passes
    path = File.join(FIXTURE_SOURCE, "fig001.jpg")
    assert Transform.valid_binary?(path)
  end

  def test_valid_png_passes
    path = File.join(FIXTURE_SOURCE, "energy", "1.png")
    assert Transform.valid_binary?(path)
  end

  def test_valid_docx_passes
    path = File.join(FIXTURE_SOURCE, "From Gravitons to Galaxies.docx")
    assert Transform.valid_binary?(path)
  end

  def test_fake_gif_fails
    path = File.join(FIXTURE_SOURCE, "greatpyramid", "fig001.gif")
    refute Transform.valid_binary?(path)
  end

  def test_php_file_skipped
    path = File.join(FIXTURE_SOURCE, "index.php")
    assert Transform.valid_binary?(path)
  end
end

class BuildIntegrationTest < Minitest::Test
  def setup
    FileUtils.rm_rf(FIXTURE_DEST)
  end

  def teardown
    FileUtils.rm_rf(FIXTURE_DEST)
  end

  def test_build_creates_docs_directory
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    assert Dir.exist?(FIXTURE_DEST)
  end

  def test_build_does_not_create_nojekyll
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    refute File.exist?(File.join(FIXTURE_DEST, ".nojekyll"))
  end

  def test_build_creates_about_page
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    assert File.exist?(File.join(FIXTURE_DEST, "about.php"))
  end

  def test_build_copies_manifest_files
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    assert File.exist?(File.join(FIXTURE_DEST, "index.php"))
    assert File.exist?(File.join(FIXTURE_DEST, "np_logo.gif"))
  end

  def test_build_excludes_junk_files
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    refute File.exist?(File.join(FIXTURE_DEST, "toolbar.php"))
  end

  def test_build_rewrites_links_in_html
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    content = File.read(File.join(FIXTURE_DEST, "index.php"))
    assert_includes content, "https://nuclearpyramid.com/"
    refute_includes content, "http://nuclearpyramid.com/"
  end

  def test_build_injects_about_nav
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    content = File.read(File.join(FIXTURE_DEST, "index.php"))
    assert_includes content, "about.php"
  end

  def test_build_rewrites_charset_in_html
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    content = File.read(File.join(FIXTURE_DEST, "index.php"))
    assert_includes content, "charset=utf-8"
    refute_includes content, "charset=iso-8859-1"
  end

  def test_build_skips_invalid_binaries
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    refute File.exist?(File.join(FIXTURE_DEST, "greatpyramid", "fig001.gif")),
      "fake image should not be copied"
  end

  def test_build_copies_valid_binaries
    Transform.build(FIXTURE_SOURCE, FIXTURE_SRC, FIXTURE_DEST)
    assert File.exist?(File.join(FIXTURE_DEST, "greatpyramid", "fig002.gif"))
  end
end

class ScaffoldingTest < Minitest::Test
  def setup
    @scaffolding_dir = File.join(FIXTURES_DIR, "scaffolding_test")
    FileUtils.rm_rf(@scaffolding_dir)
    FileUtils.mkdir_p(@scaffolding_dir)
  end

  def teardown
    FileUtils.rm_rf(@scaffolding_dir)
  end

  def test_creates_nojekyll
    Transform.write_scaffolding(@scaffolding_dir)
    assert File.exist?(File.join(@scaffolding_dir, ".nojekyll"))
  end

  def test_creates_redirect_to_site
    Transform.write_scaffolding(@scaffolding_dir)
    content = File.read(File.join(@scaffolding_dir, "index.html"))
    assert_includes content, "site/index.php"
  end
end
