#!/bin/bash

set -v
set -x
set -e

bundle install --local

# This next step iswhat we should be doing.
# However, this step behaves differently between different OSes and setups.
# So instead of running this script we copy a known good configuration of sorbet into the app

# SRB_YES=1 bundle exec srb init

# If the tests in c5s06-2-test fail because of sorbet, do the following
# * Find the latest tgz file for this step in `docker/minio/release`
# * Extract the archive
# * Run `bundle && bundle exec sorbet init`
# * Copy the contents of the `sorbet` folder into `generator_scripts/generators/c5s06-2` in this repo
# * Check in changes and rerun this step

set +x

for FILE in `find ../../generator-scripts-repo/generator_scripts/generators/c5s06-2 -type f`
do
  array=()
  DELIMITER='c5s06-2/'
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

set -x

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
