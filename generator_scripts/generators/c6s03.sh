#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves all rails_shims into the public part of the rails_shims 
# package
#
###############################################################################

mkdir -p ./packages/rails_shims/app/public
mkdir -p ./packages/rails_shims/app/public/application_cable

mv ./packages/rails_shims/app/mailers/application_mailer.rb ./packages/rails_shims/app/public
mv ./packages/rails_shims/app/models/application_record.rb ./packages/rails_shims/app/public
mv ./packages/rails_shims/app/jobs/application_job.rb ./packages/rails_shims/app/public
mv ./packages/rails_shims/app/controllers/application_controller.rb ./packages/rails_shims/app/public
mv ./packages/rails_shims/app/helpers/application_helper.rb ./packages/rails_shims/app/public
mv ./packages/rails_shims/app/channels/application_cable/connection.rb ./packages/rails_shims/app/public/application_cable
mv ./packages/rails_shims/app/channels/application_cable/channel.rb ./packages/rails_shims/app/public/application_cable

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packages/rails_shims/package.yml
