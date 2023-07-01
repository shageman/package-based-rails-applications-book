#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step generates the Sportsball sample app with a standard Rails folder
# structure
#
###############################################################################

echo "
gem 'packwerk', group: [:development, :test]
gem 'use_packs'
gem 'rspec-rails', group: [:development, :test]
gem 'shoulda-matchers', group: [:test]
gem 'slim-rails'
gem 'trueskill'
" >> Gemfile

bundle install --local

bundle binstub use_packs packwerk

rm -rf test
rails generate rspec:install

bundle exec rails g controller welcome index
sed -i "s/.*get 'welcome\/index'/  root to: 'welcome#index'/" config/routes.rb

bundle exec rails g scaffold team name:string

bundle exec rails g scaffold game date:datetime location:string \
                      first_team_id:integer second_team_id:integer \
                      winning_team:integer \
                      first_team_score:integer second_team_score:integer

bin/rails db:migrate
bin/rails db:migrate RAILS_ENV=test

sed -i "/root to: 'welcome#index'/a\\  resource :prediction, only: [:new, :create]" config/routes.rb



mkdir -p vendor/assets/javascripts
mkdir -p vendor/assets/stylesheets

mv ../../generator-scripts-repo/generator_scripts/assets/foundation-6.4.2/css/foundation.css vendor/assets/stylesheets
mv ../../generator-scripts-repo/generator_scripts/assets/foundation-6.4.2/js/vendor/foundation.js vendor/assets/javascripts

cp ../../generator-scripts-repo/generator_scripts/assets/logo.png app/assets/images/logo.png

echo '
//= link_tree ../images
//= link_directory ../stylesheets .css

//= link jquery.js
//= link foundation.js
//= link foundation.css
' > app/assets/config/manifest.js

echo '/*
 *= require foundation
 *= require_tree .
 *= require_self
 */
' > app/assets/stylesheets/application.css



rm app/helpers/games_helper.rb
rm app/helpers/teams_helper.rb
rm app/helpers/welcome_helper.rb

rm spec/helpers/games_helper_spec.rb
rm spec/helpers/teams_helper_spec.rb
rm spec/helpers/welcome_helper_spec.rb

rm spec/rails_helper.rb

rm app/views/layouts/application.html.erb

ack -l rails_helper spec | xargs sed -i "/require 'rails_helper'/d"
ack -l rails_helper spec | xargs sed -i "/require \"rails_helper\"/d"

set +x

for FILE in `find ../../generator-scripts-repo/generator_scripts/generators/c2s01 -type f`
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

  # echo ${FILE}
  # echo ${NEW_FILENAME}
  # echo ${NEW_FILEPATH}

  mkdir -p ${NEW_FILEPATH}
  set -x
  cp $FILE ${NEW_FILEPATH}
  set +x
done

set -x

bin/packwerk init

