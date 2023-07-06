#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Replace manual path load with packs-rails
#
###############################################################################

echo "

gem 'packs-rails'
" >> Gemfile

bundle install --local

sed -i '/config\.paths\.add/d' config/application.rb

echo "--require spec_helper
--require packs/rails/rspec
" > .rspec

sed -i '/append_view_path/d' packages/rails_shims/app/controllers/application_controller.rb 

sed -i '/# Adjust RSpec configuration for package folder structure/,+50d' spec/spec_helper.rb

mv packages packs

echo "pack_paths:
- packs/*
- .
" > packs.yml

find . -iname 'package.yml' -type f -print0 | xargs -0 sed -i 's/^  - packages/  - packs/g'
find . -iname 'package.yml' -type f -print0 | xargs -0 sed -i 's/^  - "packages/  - "packs/g'
find . -iname 'package.yml' -type f -print0 | xargs -0 sed -i 's/^- packages/- packs/g'
find . -iname 'package.yml' -type f -print0 | xargs -0 sed -i 's/^- "packages/- "packs/g'
