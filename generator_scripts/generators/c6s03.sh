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

mkdir -p ./packs/rails_shims/app/public
mkdir -p ./packs/rails_shims/app/public/application_cable

mv ./packs/rails_shims/app/mailers/application_mailer.rb ./packs/rails_shims/app/public
mv ./packs/rails_shims/app/models/application_record.rb ./packs/rails_shims/app/public
mv ./packs/rails_shims/app/jobs/application_job.rb ./packs/rails_shims/app/public
mv ./packs/rails_shims/app/controllers/application_controller.rb ./packs/rails_shims/app/public
mv ./packs/rails_shims/app/helpers/application_helper.rb ./packs/rails_shims/app/public
mv ./packs/rails_shims/app/channels/application_cable/connection.rb ./packs/rails_shims/app/public/application_cable
mv ./packs/rails_shims/app/channels/application_cable/channel.rb ./packs/rails_shims/app/public/application_cable

sed -i 's/enforce_privacy: false/enforce_privacy: true/g' packs/rails_shims/package.yml

echo 'inherit_from: ../../.rubocop.yml

Packs/ClassMethodsAsPublicApis:
  Enabled: false

Packs/RootNamespaceIsPackName:
  Enabled: false

Packs/TypedPublicApis:
  Enabled: false

Packs/DocumentedPublicApis:
  Enabled: false' > packs/rails_shims/.rubocop.yml
