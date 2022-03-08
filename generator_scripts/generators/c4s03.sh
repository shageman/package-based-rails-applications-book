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

echo "module Testgem
  class Engine < ::Rails::Engine
    isolate_namespace Testgem
  end
end" > testgem/lib/testgem/engine.rb

mkdir -p testgem/app/services/testgem
mkdir -p testgem/spec/services/testgem

echo "module Testgem
  class Sample
    def test
      3
    end
  end
end" > testgem/app/services/testgem/sample.rb

echo "# frozen_string_literal: true

RSpec.describe Testgem::Sample do
  it 'returns 3 when tested' do
    expect(subject.test).to eq(3)
  end
end
" > testgem/spec/services/testgem/sample_spec.rb

sed -i "s/true/false/g" testgem/spec/testgem_spec.rb

cd testgem
bundle
rake spec
cd ..

echo "gem 'testgem', path: 'testgem'" >> Gemfile
