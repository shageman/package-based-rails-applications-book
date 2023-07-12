
set -v
set -e

git --no-pager diff --name-only | grep 'VENDORED_GEMS' | xargs git checkout
git ls-files --others --exclude-standard | grep 'VENDORED_GEMS' | xargs rm

git --no-pager diff --name-only | grep 'create_teams.rb$' | xargs git checkout
git ls-files --others --exclude-standard | grep 'create_teams.rb$' | xargs rm

git --no-pager diff --name-only | grep 'create_games.rb$' | xargs git checkout
git ls-files --others --exclude-standard | grep 'create_games.rb$' | xargs rm

git --no-pager diff --name-only | grep 'schema.rb$' | xargs git checkout
git ls-files --others --exclude-standard | grep 'schema.rb$' | xargs rm

git --no-pager diff --name-only | grep '.rspec_status$' | xargs git checkout
git ls-files --others --exclude-standard | grep '.rspec_status$' | xargs rm

git --no-pager diff --name-only | grep 'vendor/cache/pocky' | xargs git checkout
git ls-files --others --exclude-standard | grep 'vendor/cache/pocky' | xargs rm

git --no-pager diff --name-only | grep 'tgz$' | xargs git checkout
git ls-files --others --exclude-standard | grep 'tgz$' | xargs rm

git --no-pager diff --name-only | grep 'credentials.yml.enc$' | xargs git checkout
git ls-files --others --exclude-standard | grep 'credentials.yml.enc$' | xargs rm

