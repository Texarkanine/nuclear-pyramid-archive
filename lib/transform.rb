# frozen_string_literal: true

require "fileutils"

module Transform
  NAV_PATTERN = /<!-- <td><a class=ttt href="\.\/proton_forum\/"><nobr>Forum<\/nobr><\/a><\/td> -->/

  ABOUT_NAV_ITEM = '<td><a class=ttt href="./about.php"><nobr>About</nobr></a></td>'

  DOCX_RELEASE_URL = "https://github.com/Texarkanine/nuclear-pyramid-archive/releases/download/2026-03-27/From.Gravitons.to.Galaxies.docx"

  TEXT_EXTENSIONS = %w[.php .html .htm].freeze

  REDIRECT_HTML = <<~HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta http-equiv="refresh" content="0; url=site/index.php">
        <title>Redirecting...</title>
      </head>
      <body>
        <p>If you are not redirected automatically, <a href="site/index.php">click here</a>.</p>
      </body>
    </html>
  HTML

  def self.rewrite_charset(html)
    html.gsub(/charset=(iso-8859-1|windows-1252)/i, "charset=utf-8")
  end

  def self.rewrite_links(html)
    html
      .gsub("http://www.nuclearpyramid.com", "https://nuclearpyramid.com")
      .gsub(/http:\/\/nuclearpyramid\.com:80(?=\/|['"\s])/, "https://nuclearpyramid.com")
      .gsub("http://nuclearpyramid.com", "https://nuclearpyramid.com")
  end

  def self.rewrite_docx_link(html)
    html.gsub(/href=(['"])From Gravitons to Galaxies\.docx\1/) do
      "href=#{$1}#{DOCX_RELEASE_URL}#{$1}"
    end
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

  def self.build(source_dir, src_dir, dest_dir)
    FileUtils.rm_rf(dest_dir)
    FileUtils.mkdir_p(dest_dir)

    Dir.glob("**/*", base: source_dir).each do |relative_path|
      src = File.join(source_dir, relative_path)
      next unless File.file?(src)

      dest = File.join(dest_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(dest))

      if TEXT_EXTENSIONS.include?(File.extname(relative_path).downcase)
        content = File.read(src, encoding: "binary")
        content.force_encoding("UTF-8")
        unless content.valid_encoding?
          content.encode!("UTF-8", "Windows-1252", invalid: :replace, undef: :replace)
        end
        content = transform_html(content)
        File.write(dest, content)
      else
        FileUtils.cp(src, dest)
      end
    end

    copy_src_files(src_dir, dest_dir) if Dir.exist?(src_dir)
  end

  def self.write_scaffolding(docs_dir)
    FileUtils.mkdir_p(docs_dir)
    File.write(File.join(docs_dir, "index.html"), REDIRECT_HTML)
    FileUtils.touch(File.join(docs_dir, ".nojekyll"))
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

  def self.transform_html(content)
    content = rewrite_links(content)
    content = rewrite_docx_link(content)
    content = inject_about_nav(content)
    rewrite_charset(content)
  end
end
