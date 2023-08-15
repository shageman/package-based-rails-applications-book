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
  - utility

package_paths:
- ./packs/*
- .
' >> packwerk.yml

echo 'enforce_architecture: true
layer: app' >> package.yml

echo 'enforce_architecture: true
layer: UI' >> packs/prediction_ui/package.yml
echo 'enforce_architecture: true
layer: UI' >> packs/welcome_ui/package.yml
echo 'enforce_architecture: true
layer: UI' >> packs/teams_admin/package.yml
# echo 'enforce_architecture: true
# layer: UI' >> packs/games_admin/package.yml

echo 'enforce_architecture: true
layer: data' >> packs/teams/package.yml
# echo 'enforce_architecture: true
# layer: data' >> packs/games/package.yml

echo 'enforce_architecture: true
layer: utility' >> packs/rails_shims/package.yml
echo 'enforce_architecture: true
layer: utility' >> packs/predictor/package.yml


## Create failure

echo 'enforce_architecture: true
layer: data' >> packs/games_admin/package.yml
echo 'enforce_architecture: true
layer: UI' >> packs/games/package.yml


## See failure

bundle install --local
bin/packwerk check && exit 1 || echo "Expected packwerk check error and got it."


## Fix it

sed -i 's/layer: data/layer: UI/' packs/games_admin/package.yml
sed -i 's/layer: UI/layer: data/' packs/games/package.yml
