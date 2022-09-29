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
  bundle | grep ffi    
  bundle exec ruby --version
  bundle exec ruby -e 'require "rbconfig"; pp RbConfig::CONFIG' | grep "cpu"
  ruby -e 'require "ffi";; module MyLib; extend FFI::Library; ffi_lib "c"; attach_function :puts, [:string], :int; end'

  bundle exec srb tc --verbose
fi

if [[ ! -z "$PACKWERK_CHECK" ]]; then
  bundle exec packwerk check
fi
