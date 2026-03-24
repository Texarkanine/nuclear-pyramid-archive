# frozen_string_literal: true

require "fileutils"

module Transform
  MANIFEST = Set.new([
    "index.php",
    "great_pyramid.php",
    "other_two_pyramids.php",
    "proton.php",
    "energy_solution.php",
    "np_logo.gif",
    "nuclides.gif",
    "From Gravitons to Galaxies.docx",
    "fig001.jpg", "fig002.jpg", "fig004.jpg",
    *(6..28).map { |n| format("fig%03d.jpg", n) },
    "fig003.gif", "fig005.gif",
    "greatpyramid/fig001.gif", "greatpyramid/fig002.gif", "greatpyramid/fig003.gif",
    "energy/1.png",
    *(2..7).map { |n| "energy/#{n}.gif" },
  ]).freeze

  BINARY_EXTENSIONS = %w[.jpg .jpeg .gif .png .docx].freeze

  MAGIC_BYTES = {
    ".jpg"  => "\xFF\xD8\xFF".b,
    ".jpeg" => "\xFF\xD8\xFF".b,
    ".gif"  => "GIF8".b,
    ".png"  => "\x89PNG".b,
    ".docx" => "PK".b,
  }.freeze

  NAV_PATTERN = /<!-- <td><a class=ttt href="\.\/proton_forum\/"><nobr>Forum<\/nobr><\/a><\/td> -->/

  ABOUT_NAV_ITEM = '<td><a class=ttt href="./about.php"><nobr>About</nobr></a></td>'

  def self.in_manifest?(path)
    MANIFEST.include?(path)
  end

  def self.rewrite_links(html)
    html
      .gsub("http://www.nuclearpyramid.com", "https://nuclearpyramid.com")
      .gsub(/http:\/\/nuclearpyramid\.com:80(?=\/|['"\s])/, "https://nuclearpyramid.com")
      .gsub("http://nuclearpyramid.com", "https://nuclearpyramid.com")
  end

  def self.inject_about_nav(html)
    return html unless html.include?("class=ttt")
    return html if html.include?("about.php")

    if html.match?(NAV_PATTERN)
      html.sub(NAV_PATTERN) { |match| "#{match}\n       #{ABOUT_NAV_ITEM}" }
    else
      html
    end
  end

  def self.valid_binary?(path)
    ext = File.extname(path).downcase
    return true unless BINARY_EXTENSIONS.include?(ext)

    expected = MAGIC_BYTES[ext]
    return true unless expected

    bytes = File.binread(path, expected.length)
    bytes&.start_with?(expected) || false
  end

  def self.build(source_dir, src_dir, dest_dir)
    FileUtils.rm_rf(dest_dir)
    FileUtils.mkdir_p(dest_dir)

    MANIFEST.each do |relative_path|
      src = File.join(source_dir, relative_path)
      next unless File.exist?(src)

      dest = File.join(dest_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(dest))

      ext = File.extname(relative_path).downcase
      if BINARY_EXTENSIONS.include?(ext)
        if valid_binary?(src)
          FileUtils.cp(src, dest)
        else
          warn "SKIPPED invalid binary: #{relative_path}"
        end
      else
        content = File.read(src, encoding: "binary")
        content.force_encoding("UTF-8")
        content.encode!("UTF-8", "Windows-1252", invalid: :replace, undef: :replace) unless content.valid_encoding?
        content = rewrite_links(content)
        content = inject_about_nav(content)
        File.write(dest, content)
      end
    end

    copy_src_files(src_dir, dest_dir) if Dir.exist?(src_dir)
    FileUtils.touch(File.join(dest_dir, ".nojekyll"))
  end

  def self.copy_src_files(src_dir, dest_dir)
    Dir.glob("**/*", base: src_dir).each do |relative_path|
      src = File.join(src_dir, relative_path)
      next unless File.file?(src)

      dest = File.join(dest_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end
  end
end
