#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add stimpack to codebase
#
###############################################################################

echo "gem 'stimpack'" >> Gemfile

bundle

sed -i '/module Sportsball/i Stimpack.config.root = "packages"' config/application.rb
sed -i '/config\.paths\.add/d' config/application.rb

echo "--require spec_helper
--require stimpack/rspec
" > .rspec

sed -i '/append_view_path/d' packages/rails_shims/app/controllers/application_controller.rb 

sed -i '/# Adjust RSpec configuration for package folder structure/,+50d' spec/spec_helper.rb

