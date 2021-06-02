#!/bin/bash

set -v
set -x
set -e

rails plugin new testengine \
  --full \
  --mountable

echo '
enforce_dependencies: true
enforce_privacy: false
' > testengine/package.yml

bundle exec
bin/packwerk update-deprecations
bin/packwerk validate
bin/rake pocky:generate[root]