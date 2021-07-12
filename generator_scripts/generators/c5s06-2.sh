#!/bin/bash

set -v
set -x
set -e

echo "
gem 'sorbet', :group => :development
gem 'sorbet-runtime'
gem 'image_processing', '~> 1.2'
" > Gemfile

bundle package

bundle exec srb typecheck -e 'puts "Hello, world!"'

bundle exec ruby -e 'puts(require "sorbet-runtime")'

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

bundle exec srb tc

find . -iname 'deprecated_references.yml' -delete

bundle install --local
bin/packwerk update-deprecations
bin/packwerk validate
bin/rake pocky:generate[root]