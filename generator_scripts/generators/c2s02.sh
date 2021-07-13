#!/bin/bash

set -v
set -x
set -e

mkdir -p app/packages/predictor/models/; mv app/models/prediction.rb $_
mkdir -p app/packages/teams/models/; mv app/models/team.rb $_
mkdir -p app/packages/games/models/; mv app/models/game.rb $_
mkdir -p app/packages/predictor/models/; mv app/models/predictor.rb $_
mkdir -p app/packages/teams_admin/controllers/; mv app/controllers/teams_controller.rb $_
mkdir -p app/packages/prediction_ui/controllers/; mv app/controllers/predictions_controller.rb $_
mkdir -p app/packages/games_admin/controllers/; mv app/controllers/games_controller.rb $_
mkdir -p app/packages/welcome_ui/controllers/; mv app/controllers/welcome_controller.rb $_
mkdir -p app/packages/welcome_ui/views/welcome; mv app/views/welcome/index.html.slim $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/edit.html.slim $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/_team.json.jbuilder $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/new.html.slim $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/_form.html.slim $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/index.json.jbuilder $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/index.html.slim $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/show.json.jbuilder $_
mkdir -p app/packages/teams_admin/views/teams; mv app/views/teams/show.html.slim $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/edit.html.slim $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/new.html.slim $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/_form.html.slim $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/index.json.jbuilder $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/index.html.slim $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/show.json.jbuilder $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/show.html.slim $_
mkdir -p app/packages/games_admin/views/games; mv app/views/games/_game.json.jbuilder $_
mkdir -p app/packages/prediction_ui/views/predictions; mv app/views/predictions/new.html.slim $_
mkdir -p app/packages/prediction_ui/views/predictions; mv app/views/predictions/create.html.slim $_
mkdir -p app/packages/prediction_ui/helpers/; mv app/helpers/predictions_helper.rb $_

mkdir -p spec/packages/teams/models; mv spec/models/team_spec.rb $_
mkdir -p spec/packages/predictor/models; mv spec/models/predictor_spec.rb $_
mkdir -p spec/packages/games/models; mv spec/models/game_spec.rb $_
mkdir -p spec/packages/games_admin/requests; mv spec/requests/games_spec.rb $_
mkdir -p spec/packages/teams_admin/requests; mv spec/requests/teams_spec.rb $_
mkdir -p spec/packages/welcome_ui/requests; mv spec/requests/welcome_spec.rb $_
mkdir -p spec/packages/prediction_ui/system; mv spec/system/predictions_spec.rb $_
mkdir -p spec/packages/games_admin/system; mv spec/system/games_spec.rb $_
mkdir -p spec/packages/teams_admin/system; mv spec/system/teams_spec.rb $_
mkdir -p spec/packages/games_admin/routing; mv spec/routing/games_routing_spec.rb $_
mkdir -p spec/packages/teams_admin/routing; mv spec/routing/teams_routing_spec.rb $_
mkdir -p spec/packages/welcome_ui/views; mv spec/views/welcome/index.html.slim_spec.rb $_
mkdir -p spec/packages/teams_admin/views; mv spec/views/teams/show.html.slim_spec.rb $_
mkdir -p spec/packages/teams_admin/views; mv spec/views/teams/new.html.slim_spec.rb $_
mkdir -p spec/packages/teams_admin/views; mv spec/views/teams/index.html.slim_spec.rb $_
mkdir -p spec/packages/teams_admin/views; mv spec/views/teams/edit.html.slim_spec.rb $_
mkdir -p spec/packages/games_admin/views; mv spec/views/games/show.html.slim_spec.rb $_
mkdir -p spec/packages/games_admin/views; mv spec/views/games/new.html.slim_spec.rb $_
mkdir -p spec/packages/games_admin/views; mv spec/views/games/index.html.slim_spec.rb $_
mkdir -p spec/packages/games_admin/views; mv spec/views/games/edit.html.slim_spec.rb $_
mkdir -p spec/packages/prediction_ui/helpers; mv spec/helpers/predictions_helper_spec.rb $_

find . -type d -empty -delete

echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/games/package.yml
echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/games_admin/package.yml
echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/prediction_ui/package.yml
echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/predictor/package.yml
echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/teams/package.yml
echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/teams_admin/package.yml
echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/welcome_ui/package.yml

sed -i "/config.eager_load_paths/a\    config.paths.add 'app/packages', glob: '*/{*,*/concerns}', eager_load: true" config/application.rb

echo "class ApplicationController < ActionController::Base
  append_view_path(Dir.glob(Rails.root.join('app/packages/*/views')))
end
" > app/controllers/application_controller.rb

echo "
# Adjust RSpec configuration for package folder structure
RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new('/spec/packages/.*/controllers')) { |metadata| metadata[:type] = :controller }
  config.define_derived_metadata(file_path: Regexp.new('/spec/packages/.*/models')) { |metadata| metadata[:type] = :model }
  config.define_derived_metadata(file_path: Regexp.new('/spec/packages/.*/requests')) { |metadata| metadata[:type] = :request }
  config.define_derived_metadata(file_path: Regexp.new('/spec/packages/.*/routing')) { |metadata| metadata[:type] = :routing }
  config.define_derived_metadata(file_path: Regexp.new('/spec/packages/.*/system')) { |metadata| metadata[:type] = :system }
  config.define_derived_metadata(file_path: Regexp.new('/spec/packages/.*/views')) { |metadata| metadata[:type] = :view }

  config.before(:each, :type => lambda {|v| v == :view}) do
    Dir.glob(Rails.root + ('app/packages/*/views')).each do |path|
      view.lookup_context.view_paths.push path
    end
  end
end
" >> spec/spec_helper.rb

echo '# See: Setting up the configuration file
# https://github.com/Shopify/packwerk/blob/main/USAGE.md#setting-up-the-configuration-file

# List of patterns for folder paths to include
# include:
# - "**/*.{rb,rake,erb}"

# List of patterns for folder paths to exclude
exclude:
- "{bin,node_modules,script,tmp,vendor}/**/*"
- "vendor/bundle/**/*"
- "**/lib/tasks/**/*.rake"

# Patterns to find package configuration files
# package_paths: "**/"

# List of application load paths
# These load paths were auto generated by Packwerk.
load_paths:
- app/channels
- app/controllers
- app/controllers/concerns
- app/helpers
- app/jobs
- app/mailers
- app/models
- app/models/concerns
- app/packages
- app/packages/games_admin/controllers
- app/packages/games_admin/deprecated_references.yml
- app/packages/games_admin/package.yml
- app/packages/games_admin/views
- app/packages/games/deprecated_references.yml
- app/packages/games/models
- app/packages/games/package.yml
- app/packages/prediction_ui/controllers
- app/packages/prediction_ui/deprecated_references.yml
- app/packages/prediction_ui/helpers
- app/packages/prediction_ui/package.yml
- app/packages/prediction_ui/views
- app/packages/predictor/models
- app/packages/predictor/package.yml
- app/packages/teams_admin/controllers
- app/packages/teams_admin/deprecated_references.yml
- app/packages/teams_admin/package.yml
- app/packages/teams_admin/views
- app/packages/teams/deprecated_references.yml
- app/packages/teams/models
- app/packages/teams/package.yml
- app/packages/welcome_ui/controllers
- app/packages/welcome_ui/deprecated_references.yml
- app/packages/welcome_ui/package.yml
- app/packages/welcome_ui/views

# List of custom associations, if any
# custom_associations:
# - "cache_belongs_to"

# Location of inflections file
# inflections_file: "config/inflections.yml"
' > packwerk.yml

bundle install --local
bundle exec packwerk update-deprecations
bin/rake pocky:generate[root]