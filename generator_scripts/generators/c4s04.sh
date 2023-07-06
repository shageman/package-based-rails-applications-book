#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# Add documented public APIs checker to app
#
###############################################################################


## Use it

echo "
gem 'rubocop-packs', require: false, group: [:development, :test]
" >> Gemfile

echo '
AllCops:
  DisabledByDefault: true

require:
  - rubocop-packs

inherit_gem:
  rubocop-packs:
    - config/default.yml
    - config/pack_config.yml

Packs/DocumentedPublicApis:
  Enabled: true' > .rubocop.yml


echo "RuboCop::Packs.configure do |config|
  config.permitted_pack_level_cops = %w(
    Packs/ClassMethodsAsPublicApis
    Packs/RootNamespaceIsPackName
    Packs/TypedPublicApis
    Packs/DocumentedPublicApis
  )
  config.required_pack_level_cops = %w()
end" > config/rubocop_packs.rb

mkdir -p spec/packs
echo "RSpec.describe 'rubocop-packs validations' do
  it { expect(RuboCop::Packs.validate).to be_empty }
end" > spec/packs/rubocop_packs_spec.rb

## Create failure

echo '
Packs/DocumentedPublicApis:
  Enabled: true' > packs/predictor/package_rubocop.yml


## See failure

bundle install --local
bundle binstub rubocop
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."


## Fix it

sed -i '/def learn/s/^/  # Pass in a list of teams and the games that they played against each other to learn relative team strengths\
  # Ensure that all teams are in the teams list if they participate in any games. Otherwise you will get a runtime error\n/' packs/predictor/app/public/predictor.rb
sed -i '/def predict/s/^/  # Pass in two teams to predict the outcome of their next game based on their learned relative team strengths\n/' packs/predictor/app/public/predictor.rb


