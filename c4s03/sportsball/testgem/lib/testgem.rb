# frozen_string_literal: true

if defined?(Rails)
  require 'testgem/engine'
else
  require 'zeitwerk'
  loader = Zeitwerk::Loader.new
  loader.tag = File.basename(__FILE__, '.rb')
  loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
  app_paths = Dir.glob(File.expand_path(File.join(__dir__, '../app', '/*')))
  app_paths.each { |k| loader.push_dir(k) }
  loader.setup
end

require_relative 'testgem/version'

module Testgem
  class Error < StandardError; end
  # Your code goes here...
end
