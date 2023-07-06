#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves Game and Team into the public part of their packages
#
###############################################################################

mkdir -p ./packs/games/app/public
mkdir -p ./packs/games/spec/public
mv ./packs/games/app/models/game.rb ./packs/games/app/public
mv ./packs/games/spec/models/game_spec.rb ./packs/games/spec/public
sed -i 's/RSpec.describe Game/RSpec.describe Game, type: :model/' ./packs/games/spec/public/game_spec.rb

mkdir -p ./packs/teams/app/public
mkdir -p ./packs/teams/spec/public
mv ./packs/teams/app/models/team.rb ./packs/teams/app/public
mv ./packs/teams/spec/models/team_spec.rb ./packs/teams/spec/public
sed -i 's/RSpec.describe Team/RSpec.describe Team, type: :model/' ./packs/teams/spec/public/team_spec.rb

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packs/games/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packs/teams/package.yml
