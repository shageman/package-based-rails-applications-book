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

bundle

sed -i '/config\.paths\.add/d' config/application.rb

echo "--require spec_helper
--require packs/rails/rspec
" > .rspec

sed -i '/append_view_path/d' packages/rails_shims/app/controllers/application_controller.rb 

sed -i '/# Adjust RSpec configuration for package folder structure/,+50d' spec/spec_helper.rb

