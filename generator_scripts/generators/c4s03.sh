#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step adds a gem (== a component) and adds zeitwerk compatible load dirs
# and adds an enginification mechanism to allow this gem to a packwerk package
#
###############################################################################

bundle install --local

sed -i "/spec.require_paths/a\\  spec.add_development_dependency 'zeitwerk'" testgem/testgem.gemspec

echo "# frozen_string_literal: true

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
end" > testgem/lib/testgem.rb

cd testgem
bundle
rake spec
cd ..
