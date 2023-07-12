# frozen_string_literal: true

require 'bundler/setup'
require 'parse_packwerk'
require 'pry'
require 'hashdiff'
# This improves the rspec diffs which should make debugging easier
require 'awesome_print'

require_relative 'support/have_matching_package'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    prefix = [File.basename($0), Process.pid].join('-') # rubocop:disable Style/SpecialGlobalVars
    tmpdir = Dir.mktmpdir(prefix)
    Dir.chdir(tmpdir) do
      example.run
    end
  ensure
    FileUtils.rm_rf(tmpdir)
  end
end

def write_file(path, content = '')
  pathname = Pathname.new(path)
  FileUtils.mkdir_p(pathname.dirname)
  pathname.write(content)
end
