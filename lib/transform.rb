# frozen_string_literal: true

require "fileutils"

module Transform
  MANIFEST = Set.new([
    "index.php",
    "great_pyramid.php",
    "other_two_pyramids.php",
    "proton.php",
    "energy_solution.php",
    "about.php",
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

  def self.generate_about_page
    <<~HTML
      <html>
      <head>
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <title>About - Nuclear Pyramid . com</title>
      <style type="text/css">
      a:link    { text-decoration: none; font-weight: normal; color: #FFFFFF; }
      a:visited { text-decoration: none; font-weight: normal; color: #FFFFFF; }
      a:active  { text-decoration: none; font-weight: normal; color: #FFFFFF; }
      a:hover   { text-decoration: none; font-weight: normal; color: #FFFFFF; }

      a.reg:link    { text-decoration: underline; font-weight: normal; color: #0000CC; }
      a.reg:visited { text-decoration: underline; font-weight: normal; color: #8800AA; }
      a.reg:active  { text-decoration: underline; font-weight: normal; color: #0000CC; }
      a.reg:hover   { text-decoration: underline; font-weight: normal; color: #000000; }

      a.ttt:link,
      a.ttt:visited,
      a.ttt:active { display: block; background: #6688CC; padding: 3px; border: 1px solid #88AAEE; color: #FFFFFF; font: 10pt Arial; letter-spacing: 1 pt; }
      a.ttt:hover { display: block; background: #AADDFF; padding: 3px; border: 1px solid #AADDFF; color: #000000; font: 10pt Arial; letter-spacing: 1 pt; }

      body      { margin: 0 }
      h1 { font-size: 18pt; font-weight: bold; padding:8px; border-bottom: 1px solid black; }
      h2 { font-size: 14pt; font-weight: bold; display:block; background: #FFFFFF; padding:8px; border-bottom: 1px solid black; }
      h3 { color: FFFFFF; font: 16pt Arial; letter-spacing: 1 pt; }
      </style>
      </head>
      <body topmargin=0 bgcolor=#AAAAAA>
      <table align=center width=720 cellspacing=0 cellpadding=0 height=100% style="border-style: solid; border-width: 0px 1px 0px 1px; border-color: #000000">
       <tr>
        <td bgcolor=#FFFFFF valign=top>
         <table width=100% cellspacing=0 cellpadding=8 height=50>
          <tr>
           <td align=left bgcolor=#4466AA>
            <h3>
             NuclearPyramid.com
            </h3>
           </td>
           <td align=right bgcolor=#4466AA>
            <table border=0 cellpadding=2 cellspacing=0><tr>
             <td><a class=ttt href="/"><nobr>Home</nobr></a></td>
             <td><a class=ttt href="./great_pyramid.php"><nobr>Great Pyramid</nobr></a></td>
             <td><a class=ttt href="./other_two_pyramids.php"><nobr>2nd &amp; 3rd Pyramids</nobr></a></td>
             <!-- <td><a class=ttt href="./proton_forum/"><nobr>Forum</nobr></a></td> -->
             <td><a class=ttt href="./about.php"><nobr>About</nobr></a></td>
            </tr></table>
           </td>
          </tr>
         </table>
         <table width=100% cellspacing=0 cellpadding=1 height=30>
          <tr>
           <td bgcolor=#FFFFFF>
          </tr>
         </table>
         <table width=640 cellspacing=0 cellpadding=0 height=50 align=center>
          <tr>
           <td>
            <span style="color: 000000; font: 12pt Times New Roman;">

      <h1>About This Archive</h1>

      <p>This page is a live archive of the original NuclearPyramid.com site. TODO: flesh out.</p>

            </span>
           </td>
          </tr>
         </table>
        </td>
       </tr>
      </table>
      </body>
      </html>
    HTML
  end

  def self.valid_binary?(path)
    ext = File.extname(path).downcase
    return true unless BINARY_EXTENSIONS.include?(ext)

    expected = MAGIC_BYTES[ext]
    return true unless expected

    bytes = File.binread(path, expected.length)
    bytes&.start_with?(expected) || false
  end

  def self.build(source_dir, dest_dir)
    FileUtils.rm_rf(dest_dir)
    FileUtils.mkdir_p(dest_dir)

    MANIFEST.each do |relative_path|
      next if relative_path == "about.php"

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

    File.write(File.join(dest_dir, "about.php"), generate_about_page)
    FileUtils.touch(File.join(dest_dir, ".nojekyll"))
  end
end
