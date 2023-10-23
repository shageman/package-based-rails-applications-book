#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add typed public apis checker to app
#
###############################################################################

## Use it

echo '
Packs/TypedPublicApis:
  Enabled: true' >> .rubocop.yml

echo '
Packs/TypedPublicApis:
  Enabled: true' >> packs/predictor/.rubocop.yml

## Create failure


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."

bin/rubocop --regenerate-todo
bundle exec visualize_packs > c4s06_a_todos.dot && dot c4s06_a_todos.dot -Tpng -o c4s06_a_todos.png


## Fix it

sed -i '/Packs\/TypedPublicApis/,+2d' packs/predictor/.rubocop.yml

echo '
Packs/TypedPublicApis:
  Enabled: false' >> packs/predictor/.rubocop.yml

# Here the fix is to remove the typing requirement for the package. We'll get back to typing in C5S07-2 and will readd this cop then

bin/rubocop --regenerate-todo
bundle exec visualize_packs > c4s06_b_fixed.dot && dot c4s06_b_fixed.dot -Tpng -o c4s06_b_fixed.png
