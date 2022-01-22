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
mv ./packages/games/app/models/game.rb ./packages/games/app/public

mkdir -p ./packages/teams/app/public
mv ./packages/teams/app/models/team.rb ./packages/teams/app/public
