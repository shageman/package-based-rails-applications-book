#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add class methods as public API checker to app
#
###############################################################################


## Use it

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: true' >> .rubocop.yml

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: true' >> packs/predictor/.rubocop.yml


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."

bin/rubocop --regenerate-todo
bundle exec visualize_packs > diagrams/all_packs_with_todo.dot && dot diagrams/all_packs_with_todo.dot -Tpng -o diagrams/all_packs_with_todo.png


## Fix it

echo '' > .rubocop_todo.yml

sed -i '/Packs\/ClassMethodsAsPublicApis/,+2d' packs/predictor/.rubocop.yml

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: false' >> packs/predictor/.rubocop.yml
