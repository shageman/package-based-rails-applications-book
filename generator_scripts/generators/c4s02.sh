#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add architecture checker to app and use it for all packages
#
###############################################################################

sed -i '/packwerk\/privacy\/checker/a\  - packwerk/architecture/checker' packwerk.yml


## Use it

echo '
architecture_layers:
  - app
  - UI
  - data
  - utility' >> packwerk.yml

echo 'enforce_architecture: true
layer: app' >> package.yml

echo 'enforce_architecture: true
layer: UI' >> packages/prediction_ui/package.yml
echo 'enforce_architecture: true
layer: UI' >> packages/welcome_ui/package.yml
echo 'enforce_architecture: true
layer: UI' >> packages/teams_admin/package.yml
# echo 'enforce_architecture: true
# layer: UI' >> packages/games_admin/package.yml

echo 'enforce_architecture: true
layer: data' >> packages/teams/package.yml
# echo 'enforce_architecture: true
# layer: data' >> packages/games/package.yml

echo 'enforce_architecture: true
layer: utility' >> packages/rails_shims/package.yml
echo 'enforce_architecture: true
layer: utility' >> packages/predictor/package.yml


## Create failure

echo 'enforce_architecture: true
layer: data' >> packages/games_admin/package.yml
echo 'enforce_architecture: true
layer: UI' >> packages/games/package.yml


## See failure

bundle install --local
bin/packwerk check && exit 1 || echo "Expected packwerk check error and got it."


## Fix it

sed -i 's/layer: data/layer: UI/' packages/games_admin/package.yml
sed -i 's/layer: UI/layer: data/' packages/games/package.yml
