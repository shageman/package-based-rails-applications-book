#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add visibility checker to app and use it for predictor
#
###############################################################################

sed -i '/packwerk\/architecture\/checker/a\  - packwerk/visibility/checker' packwerk.yml


## Use it

echo '
enforce_visibility: true
visible_to:
  - packages/games_admin' >> packages/predictor/package.yml


## See failure

bundle install --local
bin/packwerk check && exit 1 || echo "Expected packwerk check error and got it."


## Fix it

sed -i 's/packages\/games_admin/packages\/prediction_ui/' packages/predictor/package.yml
