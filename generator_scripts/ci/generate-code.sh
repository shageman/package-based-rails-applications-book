#!/usr/bin/env bash

set -v
set -x
set -e

apt-get -y update
apt-get -y install ack graphviz

gem install bundler -v 2.3.4
gem install rails

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
gem "packwerk", group: [:development, :test]
gem "pocky", group: [:development, :test], github: "shageman/pocky", branch: "main"
gem "rspec-rails", group: [:development, :test]
gem "shoulda-matchers", group: [:test]
gem "slim-rails"
gem "sorbet-runtime"
gem "sorbet", ">=0.5.10461", :group => :development
gem "trueskill"
gem "tapioca"
gem "sorbet-rails"
gem "stimpack"
' >> Gemfile

sed -i "s/gem.*tzinfo-data.*/gem 'tzinfo-data'/g" Gemfile

bundle package --all

# Move the vendored gems into a directory we control, so we can hold onto them
# This is so that all transformation steps do not fetch gems from rubygems

touch vendor/cache/.keep
mkdir VENDORED_GEMS
mv vendor/cache/* VENDORED_GEMS/

# Clean up the gemfile, so we start "fresh"
sed -i '/### GEMS NEEDED LATER/,+100d' Gemfile

cd ..

tar --exclude='tmp/*' -zcf app_`date +%Y%m%d%H%M%S`_$RAILSVERSION.tgz sportsball; echo "zipping done"