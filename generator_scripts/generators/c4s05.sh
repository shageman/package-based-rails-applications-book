#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add typed public apis checker to app
#
###############################################################################

## Use it

echo '
Packs/TypedPublicApis:
  Enabled: true' >> .rubocop.yml


## Create failure


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."


## Fix it

echo '
Packs/TypedPublicApis:
  Enabled: false' >> packs/predictor/package_rubocop.yml

# Here the fix is to remove the typing requirement for the package. We'll get back to typing in C5S07-2 and will readd this cop then