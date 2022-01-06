#!/bin/bash

set -v
set -x
set -e

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/games_admin/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/teams_admin/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/welcome_ui/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/prediction_ui/package.yml
