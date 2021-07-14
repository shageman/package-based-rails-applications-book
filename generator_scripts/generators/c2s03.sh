#!/bin/bash

set -v
set -x
set -e

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/teams
' > app/packages/games/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/games
' > app/packages/games_admin/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/games
- app/packages/teams
- app/packages/predictor
' > app/packages/prediction_ui/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
' > app/packages/teams/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/teams
' > app/packages/teams_admin/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
' > app/packages/welcome_ui/package.yml
