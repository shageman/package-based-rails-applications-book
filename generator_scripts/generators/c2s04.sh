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

echo "enforce_dependencies: true
enforce_privacy: false" > app/packages/rails_shims/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/rails_shims
- app/packages/teams
' > app/packages/games/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/rails_shims
- app/packages/games
' > app/packages/games_admin/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/rails_shims
- app/packages/games
- app/packages/teams
- app/packages/predictor
' > app/packages/prediction_ui/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/rails_shims
' > app/packages/teams/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/rails_shims
- app/packages/teams
' > app/packages/teams_admin/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- app/packages/rails_shims
' > app/packages/welcome_ui/package.yml
