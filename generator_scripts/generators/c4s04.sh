#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add folder visibility checker to app and use it for predictor
#
###############################################################################

sed -i '/packwerk\/architecture\/checker/a\  - packwerk/folder_visibility/checker' packwerk.yml

sed -i '/- packs\/*/a\- .\/packs\/*\/packs\/*' packs.yml
sed -i '/- .\/packs\/*/a\- .\/packs\/*\/packs\/*' packwerk.yml

cat packs.yml
cat packwerk.yml

## Use it

echo '
enforce_folder_visibility: true
' >> packs/predictor/package.yml


## See failure
mkdir -p packs/games_admin/packs
mv packs/predictor packs/games_admin/packs
sed -i 's/packs\/predictor/packs\/games_admin\/packs\/predictor/' packs/prediction_ui/package.yml

cat packs/prediction_ui/package.yml

bundle install --local
bin/packwerk check && exit 1 || echo "Expected packwerk check error and got it."

bin/packwerk update
bundle exec visualize_packs > diagrams/all_packs_with_todo.dot && dot diagrams/all_packs_with_todo.dot -Tpng -o diagrams/all_packs_with_todo.png

## Fix it
mkdir -p packs/prediction_ui/packs
mv packs/games_admin/packs/predictor packs/prediction_ui/packs
rm -rf packs/games_admin/packs
sed -i 's/packs\/games_admin\/packs\/predictor/packs\/prediction_ui\/packs\/predictor/' packs/prediction_ui/package.yml
