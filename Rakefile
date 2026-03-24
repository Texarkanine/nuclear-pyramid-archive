# frozen_string_literal: true

require_relative "lib/transform"
require_relative "lib/retrieve"

SOURCE_DIR = File.expand_path("archive.org", __dir__)
SRC_DIR    = File.expand_path("src", __dir__)
DOCS_DIR   = File.expand_path("docs", __dir__)
SITE_DIR   = File.join(DOCS_DIR, "site")

desc "Download pages + images from Wayback Machine into archive.org/"
task :retrieve do
  Retrieve.download_all(SOURCE_DIR)
end

desc "Transform archive.org/ into docs/site/ for publishing"
task :transform do
  Transform.build(SOURCE_DIR, SRC_DIR, SITE_DIR)
  Transform.write_scaffolding(DOCS_DIR)
  puts "Transform complete. Output in #{DOCS_DIR}"
end

desc "Full pipeline: retrieve + transform"
task build: %i[retrieve transform]

desc "Remove docs/ output directory"
task :clean do
  FileUtils.rm_rf(DOCS_DIR)
  puts "Cleaned #{DOCS_DIR}"
end

desc "Run tests"
task :test do
  Dir.glob("test/*_test.rb").each { |f| require_relative f }
end

task default: :test
