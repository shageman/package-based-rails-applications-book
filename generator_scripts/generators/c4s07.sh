#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add class methods as public API checker to app
#
###############################################################################


## Use it

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: true' >> .rubocop.yml


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."


## Fix it

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: false' >> packs/predictor/.rubocop.yml
