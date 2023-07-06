#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step removes all packwerk violations by accepting the dependencies that
# are present in the application
#
###############################################################################

bundle install --local

bin/packs add_dependency app/packages/games app/packages/teams
bin/packs add_dependency app/packages/games_admin app/packages/games
bin/packs add_dependency app/packages/prediction_ui app/packages/games
bin/packs add_dependency app/packages/prediction_ui app/packages/teams
bin/packs add_dependency app/packages/prediction_ui app/packages/predictor
bin/packs add_dependency app/packages/teams_admin app/packages/teams
