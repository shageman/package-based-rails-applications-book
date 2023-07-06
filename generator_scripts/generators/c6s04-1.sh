#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves Game and Team into the public part of their packages
#
###############################################################################

mkdir -p ./packages/games/app/public
mkdir -p ./packages/games/spec/public
mv ./packages/games/app/models/game.rb ./packages/games/app/public
mv ./packages/games/spec/models/game_spec.rb ./packages/games/spec/public
sed -i 's/RSpec.describe Game/RSpec.describe Game, type: :model/' ./packages/games/spec/public/game_spec.rb

mkdir -p ./packages/teams/app/public
mkdir -p ./packages/teams/spec/public
mv ./packages/teams/app/models/team.rb ./packages/teams/app/public
mv ./packages/teams/spec/models/team_spec.rb ./packages/teams/spec/public
sed -i 's/RSpec.describe Team/RSpec.describe Team, type: :model/' ./packages/teams/spec/public/team_spec.rb

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/games/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/teams/package.yml
