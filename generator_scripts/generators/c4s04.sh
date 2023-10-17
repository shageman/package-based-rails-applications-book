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
gem 'rubocop', require: false
" >> Gemfile

echo '
AllCops:
  DisabledByDefault: true

require:
  - rubocop-packs

inherit_gem:
  rubocop-packs:
    - config/default.yml

Packs/DocumentedPublicApis:
  Enabled: true' > .rubocop.yml

mkdir -p spec/packs
echo 'require "rubocop"

RSpec.describe "rubocop-packs validations" do
  it "has only valid config files" do
    config_files = Dir.glob("**/.rubocop.yml")
    config_files.each do |config_file|
      expect do
        config = RuboCop::ConfigLoader.load_file(File.expand_path(".") + "/.rubocop.yml", check: false)
        RuboCop::ConfigValidator.new(config).validate
      end.to_not raise_exception
    end
  end
end' > spec/packs/rubocop_packs_spec.rb

## Create failure

echo '
inherit_from: ../../.rubocop.yml

Packs/DocumentedPublicApis:
  Enabled: true' > packs/predictor/.rubocop.yml


## See failure

bundle install --local
bundle binstub rubocop
bin/rubocop && exit 1 || echo "Expected rubocop errors and got them."

bundle update visualize_packs &&  bundle exec visualize_packs > c4s04_todos.dot && dot c4s04_todos.dot -Tpng -o c4s04_todos.png


## Fix it

sed -i '/def learn/s/^/  # Pass in a list of teams and the games that they played against each other to learn relative team strengths\
  # Ensure that all teams are in the teams list if they participate in any games. Otherwise you will get a runtime error\n/' packs/predictor/app/public/predictor.rb
sed -i '/def predict/s/^/  # Pass in two teams to predict the outcome of their next game based on their learned relative team strengths\n/' packs/predictor/app/public/predictor.rb

bundle update visualize_packs &&  bundle exec visualize_packs > c4s04_fixed.dot && dot c4s04_fixed.dot -Tpng -o c4s04_fixed.png
