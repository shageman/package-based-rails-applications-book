#!/bin/bash

set -v
set -x
set -e

bundle install --local

SRB_YES=1 bundle exec srb init

echo '# typed: strict

module PredictionUi
  extend T::Sig

  sig {params(predictor: T.class_of(Predictor)).void}
  def self.configure(predictor)
    @predictor = T.let(predictor, T.nilable(T.class_of(Predictor)))
    freeze
  end

  sig {returns(T.nilable(T.class_of(Predictor)))}
  def self.predictor
    @predictor
  end
end
' > packages/prediction_ui/app/services/prediction_ui.rb
