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



## Create failure

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: true' >> packs/predictor/package_rubocop.yml


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."


## Fix it

sed -i '/Packs\/ClassMethodsAsPublicApis/,+2d' packs/predictor/package_rubocop.yml
echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: false' >> packs/predictor/package_rubocop.yml
