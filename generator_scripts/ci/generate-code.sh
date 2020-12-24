#!/usr/bin/env bash

set -v
set -x
set -e

apt-get -y update
apt-get -y install ack graphviz

gem install bundler -v 2.2.5
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
echo "
gem 'jquery-rails', '4.3.1'
gem 'packwerk', group: [:development, :test]
gem 'pocky', group: [:development, :test], github: 'shageman/pocky', branch: 'main'
gem 'rspec-rails', group: [:development, :test]
gem 'shoulda-matchers', group: [:test]
gem 'slim-rails'
gem 'trueskill'
" >> Gemfile

bundle package

cd ..

tar --exclude='tmp/*' -zcf app_`date +%Y%m%d%H%M%S`_$RAILSVERSION.tgz sportsball; echo "zipping done"