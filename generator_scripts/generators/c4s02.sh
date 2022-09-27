#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step adds a gem (== a component) into the app. Because this gem is not
# an engine, it can't be added to packwerk as such
#
###############################################################################

bundle install --local

bundle gem testgem --no-coc --no-ext --no-mit --no-rubocop --test=rspec --ci=github --no-changelog

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

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    \`git ls-files -z\`.split('\x0').reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end" > testgem/testgem.gemspec

echo "# frozen_string_literal: true

require_relative 'testgem/version'
require_relative '../app/services/testgem/sample'

module Testgem
  class Error < StandardError; end
  # Your code goes here...
end" > testgem/lib/testgem.rb

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
