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
  PredictionUi.configure(Predictor::Predictor.new)
end
' > config/initializers/configure_prediction_ui.rb

sed -i '/predictor =/c\    predictor = PredictionUi.predictor' packages/prediction_ui/app/controllers/predictions_controller.rb

sed -i '/packages\/predictor/d' packages/prediction_ui/package.yml

# swap out which packages this package is visible to: before it was packages\/prediction_ui. Now it is the root package
sed -i 's/packages\/prediction_ui/./' packages/predictor/package.yml

bundle install --local

bin/packs add_dependency . packages/prediction_ui
bin/packs add_dependency . packages/predictor
