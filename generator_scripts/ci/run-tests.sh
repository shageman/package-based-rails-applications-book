#!/usr/bin/env bash

set -v
set -x
set -e

mkdir -p gems
export GEM_HOME=`pwd`/gems
export PATH="$GEM_HOME/bin:$PATH"

tar -xzf app_code/$CHAPTER*.tgz -C app_code

cd app_code/sportsball

cp VENDORED_GEMS/* vendor/cache/ # get our saved local gems back
bundle install --local

rake db:create && rake db:migrate

bundle exec rspec --exclude-pattern '**/system/**/*_spec.rb' `cat .rspec | tr '\n' ' '`

bundle exec packwerk validate

echo 'puts Team.count' | bundle exec rails c

if [[ ! -z "$SORBET" ]]; then
  bundle exec srb tc -v 3
fi

if [[ ! -z "$PACKWERK_CHECK" ]]; then
  bundle exec packwerk check
fi
