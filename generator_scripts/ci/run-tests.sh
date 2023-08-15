#!/usr/bin/env bash

set -v
set -x
set -e

export SRB_PATH="/tmp/build/$(ls -1 /tmp/build)/gems/bin"
export PATH="$SRB_PATH:$PATH"

tar -xzf app_code/$CHAPTER*.tgz -C app_code

cd app_code/sportsball

cp -r VENDORED_GEMS/* vendor/cache/ # get our saved local gems back
bundle install --local

rake db:create && rake db:migrate

bin/rails zeitwerk:check


## TESTS FOR EVENTIDE-BACKEND
if [[ "$EVENTIDE_TESTS" = "true" ]]; then
  mkdir /usr/local/pgsql
  chown postgres /usr/local/pgsql

  su -c "/usr/lib/postgresql/14/bin/pg_ctl -D /usr/local/pgsql/data initdb" postgres
  su -c "/usr/lib/postgresql/14/bin/pg_ctl start -D  /usr/local/pgsql/data" postgres

  mkdir -p eventide-backend/prediction_component/vendor/cache/
  cp -R VENDORED_GEMS/* eventide-backend/prediction_component/vendor/cache/ 

  cd eventide-backend/prediction_component
  bundle install --local

  bundle exec rspec

  cd ../..
fi


## TESTS FOR MAIN APP
bundle exec rspec --exclude-pattern '**/system/**/*_spec.rb' `cat .rspec | tr '\n' ' '`
echo 'puts defined?(TeamRecord) ? TeamRecord.count : Team.count' | bundle exec rails c


## TYPING
if [[ "$SORBET" = "true" ]]; then
  bundle exec ruby -e 'require "rbconfig"; pp RbConfig::CONFIG' | grep "cpu"
  SRB_SORBET_EXE=/usr/local/bin/sorbet bundle exec srb tc
fi


## PACKWERK
bin/packwerk validate
bin/packwerk check
if [[ "$EXPECT_NO_PACKAGE_TODO" = "true" ]]; then
  [ "$(find . -name 'package_todo.yml')" ] && exit 1 || echo "No package todo found"
else
  [ "$(find . -name 'package_todo.yml')" ] && echo "Found package todo files!" || exit 1 
  find . -name 'package_todo.yml'
fi


## RUBOCOP
if [[ "$RUBOCOP" = "true" ]]; then
  bin/rubocop
fi
