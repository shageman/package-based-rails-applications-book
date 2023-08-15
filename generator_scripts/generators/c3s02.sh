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



sed -i "/spec.homepage/d" testgem/testgem.gemspec
sed -i "/spec.metadata\[.homepage_uri.\]/d" testgem/testgem.gemspec
sed -i "/spec.metadata\[.source_code_uri.\]/d" testgem/testgem.gemspec
sed -i "/spec.metadata\[.changelog_uri.\]/d" testgem/testgem.gemspec
sed -i "/allowed_push_host/c\  spec.metadata['allowed_push_host'] = 'http://nowhere.atall'" testgem/testgem.gemspec
sed -i "s/TODO: //g" testgem/testgem.gemspec
sed -i "s/TODO//g" testgem/testgem.gemspec



sed -i "/require_relative/a\require_relative '..\/app\/services\/testgem\/sample'" testgem/lib/testgem.rb


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
mkdir -p vendor/cache
cp -R ../VENDORED_GEMS/* vendor/cache/
cp -R ../.bundle .bundle

sed -i '/rspec/c\gem "rspec-core"\
gem "rspec-expectations"
' Gemfile

bundle install --local
bundle exec rspec
cd ..

echo "gem 'testgem', path: 'testgem'" >> Gemfile

echo 'enforce_dependencies: true' > testgem/package.yml

echo '
package_paths:
- ./packs/*
- .
- ./testgem
' >> packwerk.yml

sed -i '/pack_paths/a\- ./testgem' packs.yml
