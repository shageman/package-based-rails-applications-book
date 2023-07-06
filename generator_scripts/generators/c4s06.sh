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
  Enabled: true' >> .rubocop.yml


## Create failure

echo '
Packs/RootNamespaceIsPackName:
  Enabled: true' >> packages/predictor/package_rubocop.yml


## See failure

bundle install --local
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."


## Fix it

find . -type f

mkdir packages/predictor/app/public/predictor
mv packages/predictor/app/public/predictor.rb packages/predictor/app/public/predictor/predictor.rb
cat packages/predictor/app/public/predictor/predictor.rb

cat packages/predictor/app/public/predictor/predictor.rb | sed 's/\(.*\)/  \1/' | tee packages/predictor/app/public/predictor/predictor2.rb
rm packages/predictor/app/public/predictor/predictor.rb
mv packages/predictor/app/public/predictor/predictor2.rb packages/predictor/app/public/predictor/predictor.rb
cat packages/predictor/app/public/predictor/predictor.rb

sed -i 's/  require "saulabs\/trueskill"/require "saulabs\/trueskill"/' packages/predictor/app/public/predictor/predictor.rb
cat packages/predictor/app/public/predictor/predictor.rb

sed -i '/class Predictor/s/^/module Predictor\n/' packages/predictor/app/public/predictor/predictor.rb
cat packages/predictor/app/public/predictor/predictor.rb

echo "
end" >> packages/predictor/app/public/predictor/predictor.rb
cat packages/predictor/app/public/predictor/predictor.rb

mkdir packages/predictor/app/models/predictor
mv packages/predictor/app/models/prediction.rb packages/predictor/app/models/predictor/prediction.rb
cat packages/predictor/app/models/predictor/prediction.rb

cat packages/predictor/app/models/predictor/prediction.rb | sed 's/\(.*\)/  \1/' | tee packages/predictor/app/models/predictor/prediction2.rb
rm packages/predictor/app/models/predictor/prediction.rb
mv packages/predictor/app/models/predictor/prediction2.rb packages/predictor/app/models/predictor/prediction.rb
cat packages/predictor/app/models/predictor/prediction.rb

sed -i '/class Prediction/s/^/module Predictor\n/' packages/predictor/app/models/predictor/prediction.rb
cat packages/predictor/app/models/predictor/prediction.rb

echo "
end" >> packages/predictor/app/models/predictor/prediction.rb
cat packages/predictor/app/models/predictor/prediction.rb

mkdir packages/predictor/spec/models/predictor
mv packages/predictor/spec/models/predictor_spec.rb packages/predictor/spec/models/predictor/predictor_spec.rb
sed -i 's/Predictor/Predictor::Predictor/g' packages/predictor/spec/models/predictor/predictor_spec.rb
sed -i 's/Prediction/Predictor::Prediction/g' packages/predictor/spec/models/predictor/predictor_spec.rb

sed -i 's/Predictor/Predictor::Predictor/g' packages/prediction_ui/app/controllers/predictions_controller.rb
