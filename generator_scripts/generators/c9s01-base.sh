#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# League-based version of the eventide-based event-sourced and CQRS-based prediction engine
#
###############################################################################

for FILE in `find ../../generator-scripts-repo/generator_scripts/generators/$1 -type f`
do
  array=()
  DELIMITER="$1/"
  PARTS=$FILE$DELIMITER
  while test "$PARTS"
  do
      array+=( "${PARTS%%"$DELIMITER"*}" )
      PARTS=${PARTS#*"$DELIMITER"}
  done
  NEW_FILENAME=${array[1]}
  NEW_FILEPATH=$(/usr/bin/dirname $NEW_FILENAME)

  # echo ${FILE}
  # echo ${NEW_FILENAME}
  # echo ${NEW_FILEPATH}

  mkdir -p ${NEW_FILEPATH}
  set -x
  cp $FILE ${NEW_FILEPATH}
  set +x
done

echo '--ignore=/eventide-backend' >> sorbet/config

mkdir -p eventide-backend/prediction_component/.bundle/
echo '---
BUNDLE_CACHE_ALL: "true"' > eventide-backend/prediction_component/.bundle/config

rm -rf packs/predictor

sed -i '/- packs\/predictor/d' package.yml

rm config/initializers/configure_prediction_ui.rb

cp -R eventide-backend/prediction_component/settings .

echo "gem 'prediction_component', path: 'eventide-backend/prediction_component'" >> Gemfile




sed -i '/RSpec.describe/a\ \
  def startup_sleep\
    puts "Sleeping to wait for startup of server. Results are non-deterministic."\
    sleep 3\
  end\
\
  before(:context) do\
    \`echo "\\n\\n\\n\\n>>>>>>>>>> NEW TEST RUN <<<<<<<<<<"\`\
    \`date +"%Y-%m-%d %T"\`\
    puts "*** Scrubbing message DB"\
    puts \`PGUSER=root bundle exec mdb-recreate-db\`\
    # puts "*** Messages Status Before Tests"\
    # puts \`PGUSER=postgres bundle exec mdb-print-messages\`\
\
    # puts \`PGUSER=postgres STREAM_NAME=someStream-111 bundle exec mdb-write-test-message\`\
    \
    puts \`PGUSER=postgres bundle exec mdb-print-messages\`\
    puts "*** Starting ComponentHost"\
    fork { exec("PGUSER=postgres ruby eventide-backend/prediction_component/lib/service.rb") }\
    startup_sleep\
  end\
\
  after (:context) do\
    \`ps ax | grep "ruby eventide-backend/prediction_component/lib/service.rb" | awk '\''{print "kill -s TERM " $1}'\'' | sh\`\
  end
' packs/prediction_ui/spec/system/predictions_spec.rb

cat packs/prediction_ui/spec/system/predictions_spec.rb


