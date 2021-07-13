#!/usr/bin/env bash

set -v
set -x
set -e

pwd

mkdir -f gems
export GEM_HOME=`pwd`/gems

tar -xzf app_code/$CHAPTER*.tgz -C app_code

cd app_code/sportsball

bundle

rspec spec --exclude-pattern "**/system/**/*_spec.rb"

bundle exec packwerk validate

if [[ ! -z "$SORBET" ]]; then
  bundle exec srb tc
fi

if [[ ! -z "$PACKWERK_CHECK" ]]; then
  bundle exec packwerk check
fi
