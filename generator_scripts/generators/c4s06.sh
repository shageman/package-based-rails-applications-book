#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add Root namespace is pack name checker to app
#
###############################################################################


## Use it

echo '
Packs/RootNamespaceIsPackName:
  Enabled: false' >> .rubocop.yml


## Create failure

echo '
Packs/RootNamespaceIsPackName:
  Enabled: true' >> packs/predictor/.rubocop.yml


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."

bundle update visualize_packs &&  bundle exec visualize_packs > c4s06_todos.dot && dot c4s06_todos.dot -Tpng -o c4s06_todos.png


## Fix it

find . -type f

mkdir packs/predictor/app/public/predictor
mv packs/predictor/app/public/predictor.rb packs/predictor/app/public/predictor/predictor.rb
cat packs/predictor/app/public/predictor/predictor.rb

cat packs/predictor/app/public/predictor/predictor.rb | sed 's/\(.*\)/  \1/' | tee packs/predictor/app/public/predictor/predictor2.rb
rm packs/predictor/app/public/predictor/predictor.rb
mv packs/predictor/app/public/predictor/predictor2.rb packs/predictor/app/public/predictor/predictor.rb
cat packs/predictor/app/public/predictor/predictor.rb

sed -i 's/  require "saulabs\/trueskill"/require "saulabs\/trueskill"/' packs/predictor/app/public/predictor/predictor.rb
cat packs/predictor/app/public/predictor/predictor.rb

sed -i '/class Predictor/s/^/module Predictor\n/' packs/predictor/app/public/predictor/predictor.rb
cat packs/predictor/app/public/predictor/predictor.rb

echo "
end" >> packs/predictor/app/public/predictor/predictor.rb
cat packs/predictor/app/public/predictor/predictor.rb

mkdir packs/predictor/app/models/predictor
mv packs/predictor/app/models/prediction.rb packs/predictor/app/models/predictor/prediction.rb
cat packs/predictor/app/models/predictor/prediction.rb

cat packs/predictor/app/models/predictor/prediction.rb | sed 's/\(.*\)/  \1/' | tee packs/predictor/app/models/predictor/prediction2.rb
rm packs/predictor/app/models/predictor/prediction.rb
mv packs/predictor/app/models/predictor/prediction2.rb packs/predictor/app/models/predictor/prediction.rb
cat packs/predictor/app/models/predictor/prediction.rb

sed -i '/class Prediction/s/^/module Predictor\n/' packs/predictor/app/models/predictor/prediction.rb
cat packs/predictor/app/models/predictor/prediction.rb

echo "
end" >> packs/predictor/app/models/predictor/prediction.rb
cat packs/predictor/app/models/predictor/prediction.rb

mkdir packs/predictor/spec/models/predictor
mv packs/predictor/spec/models/predictor_spec.rb packs/predictor/spec/models/predictor/predictor_spec.rb
sed -i 's/Predictor/Predictor::Predictor/g' packs/predictor/spec/models/predictor/predictor_spec.rb
sed -i 's/Prediction/Predictor::Prediction/g' packs/predictor/spec/models/predictor/predictor_spec.rb

sed -i 's/Predictor/Predictor::Predictor/g' packs/prediction_ui/app/controllers/predictions_controller.rb

bundle update visualize_packs &&  bundle exec visualize_packs > c4s06_fixed.dot && dot c4s06_fixed.dot -Tpng -o c4s06_fixed.png
