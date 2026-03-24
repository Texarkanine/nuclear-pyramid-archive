# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/transform"

FIXTURES_DIR = File.expand_path("fixtures", __dir__)
FIXTURE_SOURCE = File.join(FIXTURES_DIR, "archive.org")
FIXTURE_DEST = File.join(FIXTURES_DIR, "docs")
