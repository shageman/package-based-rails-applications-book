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
bundle exec visualize_packs > c4s07_a_todos.dot && dot c4s07_a_todos.dot -Tpng -o c4s07_a_todos.png


## Fix it

sed -i '/Packs\/ClassMethodsAsPublicApis/,+2d' packs/predictor/.rubocop.yml

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: false' >> packs/predictor/.rubocop.yml

bin/rubocop --regenerate-todo
bundle exec visualize_packs > c4s07_b_fixed.dot && dot c4s07_b_fixed.dot -Tpng -o c4s07_b_fixed.png
