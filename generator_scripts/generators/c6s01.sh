#!/bin/bash

set -v
set -x
set -e

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

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/games_admin/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/teams_admin/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/welcome_ui/package.yml
sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/prediction_ui/package.yml

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/predictor_interface/package.yml
