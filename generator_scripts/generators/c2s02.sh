#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves all domain code from the app/ folder into packages inside of
# app/packages 
#
###############################################################################

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

echo "enforce_dependencies: true" > app/packages/games/package.yml
echo "enforce_dependencies: true" > app/packages/games_admin/package.yml
echo "enforce_dependencies: true" > app/packages/prediction_ui/package.yml
echo "enforce_dependencies: true" > app/packages/predictor/package.yml
echo "enforce_dependencies: true" > app/packages/teams/package.yml
echo "enforce_dependencies: true" > app/packages/teams_admin/package.yml
echo "enforce_dependencies: true" > app/packages/welcome_ui/package.yml



sed -i '/config.eager_load_paths/a\    config.eager_load_paths += Dir.glob("#{root}/app/packages/*/{*,*/concerns}")' config/application.rb

sed -i "/ApplicationController/a\  append_view_path(Dir.glob(Rails.root.join('app\/packages\/*\/views')))" app/controllers/application_controller.rb

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
      view.lookup_context.append_view_paths [path]
    end
  end
end
" >> spec/spec_helper.rb

bundle install --local
