# frozen_string_literal: true

require_relative "lib/transform"
require_relative "lib/retrieve"

SOURCE_DIR = File.expand_path("archive.org", __dir__)
SRC_DIR    = File.expand_path("src", __dir__)
DEST_DIR   = File.expand_path("docs", __dir__)

desc "Bulk-download site from Wayback Machine into archive.org/"
task :retrieve do
  Retrieve.bulk_download(SOURCE_DIR)
end

namespace :retrieve do
  desc "Fetch specific pages from known-good Wayback snapshots"
  task :targeted do
    Retrieve.fetch_targeted(SOURCE_DIR)
  end
end

desc "Transform archive.org/ into docs/ for publishing"
task :transform do
  Transform.build(SOURCE_DIR, SRC_DIR, DEST_DIR)
  puts "Transform complete. Output in #{DEST_DIR}"
end

desc "Full pipeline: retrieve + transform"
task build: [:retrieve, "retrieve:targeted", :transform]

desc "Remove docs/ output directory"
task :clean do
  FileUtils.rm_rf(DEST_DIR)
  puts "Cleaned #{DEST_DIR}"
end

desc "Run tests"
task :test do
  Dir.glob("test/*_test.rb").each { |f| require_relative f }
end

task default: :test
