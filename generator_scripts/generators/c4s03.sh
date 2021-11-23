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

bundle gem testgem --no-coc --no-ext --no-mit --no-rubocop --test=rspec --ci=github

rm -rf testgem/.git
rm -rf testgem/.gitignore

echo "# frozen_string_literal: true

require_relative 'lib/testgem/version'

Gem::Specification.new do |spec|
  spec.name          = 'testgem'
  spec.version       = Testgem::VERSION
  spec.authors       = ['Stephan Hagemann']
  spec.email         = ['stephan.hagemann@gmail.com']

  spec.summary       = 'Write a short summary, because RubyGems requires one.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.required_ruby_version = '>= 2.4.0'

  spec.metadata['allowed_push_host'] = 'Set to http://mygemserver.com'

  spec.files = Dir['app/**/*.rb', 'lib/**/*.rb'] + Dir['bin/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'zeitwerk'
end" > testgem/testgem.gemspec

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

sed -i "/packages.welcome_ui.app.views/a - testgem/app/services" packwerk.yml

echo "gem 'testgem', path: 'testgem'" >> Gemfile
