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

mkdir -p packs/prediction_ui/app/services

echo 'module PredictionUi
  def self.configure(predictor)
    @predictor = predictor
    freeze
  end

  def self.predictor
    @predictor
  end
end
' > packs/prediction_ui/app/services/prediction_ui.rb

echo 'Rails.application.config.to_prepare do
  PredictionUi.configure(Predictor::Predictor.new)
end
' > config/initializers/configure_prediction_ui.rb

sed -i '/predictor =/c\    predictor = PredictionUi.predictor' packs/prediction_ui/app/controllers/predictions_controller.rb

sed -i '/packs\/predictor/d' packs/prediction_ui/package.yml

# swap out which packages this package is visible to: before it was packs\/prediction_ui. Now it is the root package
sed -i 's/packs\/prediction_ui/./' packs/predictor/package.yml

bundle install --local

bin/packs add_dependency . packs/prediction_ui
bin/packs add_dependency . packs/predictor
