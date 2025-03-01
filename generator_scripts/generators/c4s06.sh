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


# Turn off rubocop config loading optimization that prevents nested configs from being considered
sed -i '/ARGV.unshift/ s/^/#/' bin/rubocop


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
bundle exec visualize_packs > diagrams/all_packs_with_todo.dot && dot diagrams/all_packs_with_todo.dot -Tpng -o diagrams/all_packs_with_todo.png


## Fix it

echo '' > .rubocop_todo.yml

sed -i '/Packs\/TypedPublicApis/,+2d' packs/predictor/.rubocop.yml

echo '
Packs/TypedPublicApis:
  Enabled: false' >> packs/predictor/.rubocop.yml

# Here the fix is to remove the typing requirement for the package. We'll get back to typing in C5S07-2 and will readd this cop then
