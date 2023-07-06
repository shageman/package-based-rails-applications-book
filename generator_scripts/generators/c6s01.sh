#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step adds privacy protection for all packages for which it doesn't cause
# violations in the current state. The current state is derived from c5s07-3
# to have typing.
#
###############################################################################

sed -i 's/enforce_privacy: false/enforce_privacy: true/' ./package.yml

echo '
enforce_privacy: true' >> packs/games_admin/package.yml
echo '
enforce_privacy: true' >> packs/teams_admin/package.yml
echo '
enforce_privacy: true' >> packs/welcome_ui/package.yml

# TODO
# sed -i 's/enforce_privacy: false/enforce_privacy: true/' packs/prediction_ui/package.yml

echo '
enforce_privacy: true' >> packs/predictor_interface/package.yml
