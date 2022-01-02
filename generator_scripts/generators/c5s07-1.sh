#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step makes the app use dependency injection to the prediction_ui, so it
# no longer references Predictor directly
#
###############################################################################

mkdir -p packages/prediction_ui/app/services

echo 'module PredictionUi
  def self.configure(predictor)
    @predictor = predictor
    freeze
  end

  def self.predictor
    @predictor
  end
end
' > packages/prediction_ui/app/services/prediction_ui.rb

echo 'Rails.application.config.to_prepare do
  PredictionUi.configure(Predictor.new)
end
' > config/initializers/configure_prediction_ui.rb

echo 'class PredictionsController < ApplicationController
  def new
    @teams = Team.all
  end

  def create
    predictor.learn(Team.all, Game.all)
    @prediction = predictor.predict(
        Team.find(params["first_team"]["id"]),
        Team.find(params["second_team"]["id"]))
  end
end
' > packages/prediction_ui/app/controllers/predictions_controller.rb

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/rails_shims
- packages/games
- packages/teams
' > packages/prediction_ui/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/prediction_ui
- packages/predictor
' > package.yml