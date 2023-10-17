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


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."

bundle update visualize_packs &&  bundle exec visualize_packs > c4s07_todos.dot && dot c4s07_todos.dot -Tpng -o c4s07_todos.png


## Fix it

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: false' >> packs/predictor/.rubocop.yml

bundle update visualize_packs &&  bundle exec visualize_packs > c4s07_fixed.dot && dot c4s07_fixed.dot -Tpng -o c4s07_fixed.png
