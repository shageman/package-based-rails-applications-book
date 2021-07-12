#!/usr/bin/env bash

set -v
set -x

tar -xzf app_code/$CHAPTER*.tgz -C app_code

cd app_code/sportsball

bundle

rspec spec --exclude-pattern "**/system/**/*_spec.rb"

if [[ -z "${SORBET}" ]]; then
  bundle exec srb tc
fi

exit $?