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

echo '--require spec_helper
--require stimpack/rspec
' > .rspec

sed -i '/module Sportsball/i Stimpack.config.root = "packages"' config/application.rb

sed -i '/append_view_path/d' packages/rails_shims/app/public/application_controller.rb 

