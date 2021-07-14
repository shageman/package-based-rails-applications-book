#!/usr/bin/env bash

set -v
set -x
set -e

mkdir -p gems
export GEM_HOME=`pwd`/gems
export PATH="$GEM_HOME/bin:$PATH"

tar -xzf app_code/$CHAPTER*.tgz -C app_code

cd app_code/sportsball

bundle install --local

bundle exec rspec --exclude-pattern '**/system/**/*_spec.rb' `cat .rspec | tr '\n' ' '`

bundle exec packwerk validate

if [[ ! -z "$SORBET" ]]; then
  bundle exec srb tc
fi

if [[ ! -z "$PACKWERK_CHECK" ]]; then
  bundle exec packwerk check
fi
