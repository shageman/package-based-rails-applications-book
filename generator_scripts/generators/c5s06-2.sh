#!/bin/bash

set -v
set -x
set -e

bundle install --local

# This next step iswhat we should be doing.
# However, this step behaves differently between different OSes and setups.
# So instead of running this script we copy a known good configuration of sorbet into the app

# SRB_YES=1 bundle exec srb init

for FILE in `find ../../generator-scripts-repo/generator_scripts/generators/c5s06-2 -type f`
do
  array=()
  DELIMITER='c2s01/'
  PARTS=$FILE$DELIMITER
  while test "$PARTS"
  do
      array+=( "${PARTS%%"$DELIMITER"*}" )
      PARTS=${PARTS#*"$DELIMITER"}
  done
  NEW_FILENAME=${array[1]}
  NEW_FILEPATH=$(/usr/bin/dirname $NEW_FILENAME)

  echo ${FILE}
  echo ${NEW_FILENAME}
  echo ${NEW_FILEPATH}

  mkdir -p -p ${NEW_FILEPATH}
  cp $FILE ${NEW_FILEPATH}
done

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
