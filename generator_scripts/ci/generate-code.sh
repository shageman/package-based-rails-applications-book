#!/usr/bin/env bash

set -v
set -x
set -e

gem install bundler -v 2.3.4
gem install rails -v 7.2.2.1

RAILSVERSION=`rails -v | sed 's/ /_/g'`

cd code_output

#!/bin/bash

set -v
set -x
set -e

rails new sportsball
cd sportsball

rm -rf .git

sed -i 's/'"'"'/"/g' Gemfile
echo '
### GEMS NEEDED LATER

gem "image_processing", "~> 1.2"
gem "jquery-rails", "4.3.1"
gem "rspec-rails", group: [:development, :test]
gem "shoulda-matchers", group: [:test]
gem "slim-rails"
gem "sorbet-runtime"
gem "sorbet", ">=0.5.10461", :group => :development
gem "trueskill"
gem "tapioca"

## Add all RubyAtScale gems
gem "packwerk", group: [:development, :test]
gem "code_ownership"
gem "pack_stats"
gem "visualize_packs"
gem "parse_packwerk"
gem "packs"
gem "packwerk-extensions"
gem "rubocop-packs"
gem "code_teams"
gem "danger-packwerk"
gem "packs-rails"
gem "code_manifest"

### eventide gems
gem "eventide-postgres"
gem "evt-component_host"
gem "evt-try"
gem "rspec"

### hanami gems
gem "hanami", github: "hanami/hanami", branch: "exclude-more-files-from-zeitwerk"
gem "hanami-view", github: "hanami/view", branch: "exclude-more-files-from-zeitwerk"
gem "hanami-controller", ">= 2.2"
gem "dry-operation"
' >> Gemfile

sed -i "s/gem.*tzinfo-data.*/gem 'tzinfo-data'/g" Gemfile

bundle cache --all --all-platforms

# Move the vendored gems into a directory we control, so we can hold onto them
# This is so that all transformation steps do not fetch gems from rubygems

touch vendor/cache/.keep
mkdir VENDORED_GEMS
mv vendor/cache/* VENDORED_GEMS/

# Clean up the gemfile, so we start "fresh"
sed -i '/### GEMS NEEDED LATER/,+100d' Gemfile

cd ..

tar --exclude='tmp/*' -zcf app-`date +%Y%m%d%H%M%S`_$RAILSVERSION.tgz sportsball; echo "zipping done"