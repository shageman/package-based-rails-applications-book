#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add privacy checker to app and use it for predictor
#
###############################################################################

echo "

gem 'packwerk-extensions', group: [:development, :test]
" >> Gemfile

echo "
require:
  - packwerk/privacy/checker" >> packwerk.yml


## Use it

echo "
enforce_privacy: true" >> packs/predictor/package.yml


## See failure

bundle install --local
bin/packwerk check && exit 1 || echo "Expected packwerk check error and got it."


## Fix it

mkdir packs/predictor/app/public
mv packs/predictor/app/models/predictor.rb packs/predictor/app/public

bundle install --local
bin/packwerk check && echo "Expected no packwerk check error and got none."
