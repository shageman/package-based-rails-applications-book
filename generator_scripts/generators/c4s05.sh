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


## Create failure


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."

bundle update visualize_packs &&  bundle exec visualize_packs > c4s05_todos.dot && dot c4s05_todos.dot -Tpng -o c4s05_todos.png


## Fix it

echo '
Packs/TypedPublicApis:
  Enabled: false' >> packs/predictor/.rubocop.yml

# Here the fix is to remove the typing requirement for the package. We'll get back to typing in C5S07-2 and will readd this cop then

bundle update visualize_packs &&  bundle exec visualize_packs > c4s05_fixed.dot && dot c4s05_fixed.dot -Tpng -o c4s05_fixed.png
