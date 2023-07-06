#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves Rails-related base classes into their own rails_shims package 
#
###############################################################################

mkdir -p app/packages/rails_shims/mailers/; mv app/mailers/application_mailer.rb $_
mkdir -p app/packages/rails_shims/models/; mv app/models/application_record.rb $_
mkdir -p app/packages/rails_shims/models/concerns/; mv app/models/concerns/.keep $_
mkdir -p app/packages/rails_shims/jobs/; mv app/jobs/application_job.rb $_
mkdir -p app/packages/rails_shims/controllers/; mv app/controllers/application_controller.rb $_
mkdir -p app/packages/rails_shims/controllers/concerns/; mv app/controllers/concerns/.keep $_
mkdir -p app/packages/rails_shims/helpers/; mv app/helpers/application_helper.rb $_
mkdir -p app/packages/rails_shims/channels/application_cable/; mv app/channels/application_cable/connection.rb $_
mkdir -p app/packages/rails_shims/channels/application_cable/; mv app/channels/application_cable/channel.rb $_

find . -type d -empty -delete

echo "enforce_dependencies: true" > app/packages/rails_shims/package.yml

bundle install --local

bin/packs add_dependency app/packages/games app/packages/rails_shims
bin/packs add_dependency app/packages/games_admin app/packages/rails_shims
bin/packs add_dependency app/packages/prediction_ui app/packages/rails_shims
bin/packs add_dependency app/packages/teams app/packages/rails_shims
bin/packs add_dependency app/packages/teams_admin app/packages/rails_shims
bin/packs add_dependency app/packages/welcome_ui app/packages/rails_shims
