#!/bin/bash

set -v
set -x
set -e

mkdir -p packages/prediction_needed_subscriber/app/public
mv packages/predictor/app/models/prediction_needed_subscriber.rb packages/prediction_needed_subscriber/app/public

echo 'enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/games
- packages/teams
- packages/predictor
' > packages/prediction_needed_subscriber/package.yml

