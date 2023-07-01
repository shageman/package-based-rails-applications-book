#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step adds privacy protection for all packages for which it doesn't cause
# violations in the current state. The current state is derived from c5s07-3
# to have typing but removes the dependency injection introduced there.
#
###############################################################################

echo "
gem 'packwerk-extensions'
" >> Gemfile

echo "
require:
  - packwerk-extensions
" >> packwerk.yml

rm packages/prediction_ui/app/services/prediction_ui.rb
rm config/initializers/configure_prediction_ui.rb

echo 'class PredictionsController < ApplicationController
  def new
    @teams = Team.all
  end

  def create
    predictor = Predictor.new
    predictor.learn(Team.all, Game.all)
    @prediction = predictor.predict(
        Team.find(params["first_team"]["id"]),
        Team.find(params["second_team"]["id"]))
  end
end
' > packages/prediction_ui/app/controllers/predictions_controller.rb

echo 'enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/games
- packages/predictor_interface
- packages/predictor
- packages/rails_shims
- packages/teams
' > packages/prediction_ui/package.yml


sed -i 's/enforce_privacy: false/enforce_privacy: true/g' ./package.yml

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/games_admin/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/teams_admin/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/welcome_ui/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/prediction_ui/package.yml

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/predictor_interface/package.yml
