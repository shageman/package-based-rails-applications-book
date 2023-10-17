#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add visibility checker to app and use it for predictor
#
###############################################################################

sed -i '/packwerk\/architecture\/checker/a\  - packwerk/visibility/checker' packwerk.yml


## Use it

echo '
enforce_visibility: true
visible_to:
  - packs/games_admin' >> packs/predictor/package.yml

bundle update visualize_packs &&  bundle exec visualize_packs > c4s03_todos.dot && dot c4s03_todos.dot -Tpng -o c4s03_todos.png


## See failure

bundle install --local
bin/packwerk check && exit 1 || echo "Expected packwerk check error and got it."


## Fix it

sed -i 's/packs\/games_admin/packs\/prediction_ui/' packs/predictor/package.yml

bundle update visualize_packs &&  bundle exec visualize_packs > c4s03_fixed.dot && dot c4s03_fixed.dot -Tpng -o c4s03_fixed.png
