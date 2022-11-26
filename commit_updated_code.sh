
set -v
set -e



git ls-files --others --exclude-standard | grep 'VENDORED_GEMS' | xargs rm
git --no-pager diff --name-only | grep '\.gem$' | xargs git add
git ls-files --others --exclude-standard | grep '\.gem$' | xargs git add

git commit -m "Updated chapters' sportsball app gems"



git --no-pager diff --name-only | grep 'create_teams.rb$' | xargs git checkout
git --no-pager diff --name-only | grep 'create_games.rb$' | xargs git checkout
git ls-files --others --exclude-standard | grep 'create_teams.rb$' | xargs rm
git ls-files --others --exclude-standard | grep 'create_games.rb$' | xargs rm



git ls-files --others --exclude-standard | grep 'vendor/cache/pocky' | xargs rm
