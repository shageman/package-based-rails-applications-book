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


## See failure

bundle install --local
bin/packwerk check && exit 1 || echo "Expected packwerk check error and got it."

bin/packwerk update
bundle exec visualize_packs > diagrams/all_packs_with_todo.dot && dot diagrams/all_packs_with_todo.dot -Tpng -o diagrams/all_packs_with_todo.png

## Fix it

sed -i 's/packs\/games_admin/packs\/prediction_ui/' packs/predictor/package.yml
