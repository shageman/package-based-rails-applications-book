#!/usr/bin/env bash

set -v
set -x
set -e

# mkdir -p gems
# export GEM_HOME=`pwd`/gems
# echo $GEM_HOME
export SRB_PATH="/tmp/build/$(ls -1 /tmp/build)/gems/bin"
export PATH="$SRB_PATH:$PATH"

gem install bundler -v 2.3.4

tar -xzf code_input/$PREV_CHAPTER*.tgz -C code_output

cd code_output/sportsball

rm -f c*.dot
rm -f c*.png
rm -rf diagrams
mkdir diagrams

cp -r VENDORED_GEMS/* vendor/cache/ # get our saved local gems back

../../generator-scripts-repo/generator_scripts/generators/$CHAPTER.sh

find . -iname 'package_todo.yml' -delete
bundle install --local
bin/packwerk update

bundle exec visualize_packs > diagrams/all_packs.dot && dot diagrams/all_packs.dot -Tpng -o diagrams/all_packs.png

# for file in $(find . -name package.yml); do
#   if ! [[ $file == *"VENDORED_GEMS"* ]] && ! [[ $file == *"vendor"* ]]; then
#     package_name=`echo $file | sed 's/\/package.yml//g' | sed 's/\.\///'`
#     output_name=`echo $package_name | sed 's/\//_/' | sed 's/\._/root_/'`

#     bundle exec visualize_packs --focus_on=$package_name > diagrams/$output_name.dot && dot diagrams/$output_name.dot -Tpng -o diagrams/$output_name.png
#     bundle exec visualize_packs --focus_on=$package_name --only-edges-to-focus > diagrams/${output_name}_focus.dot && dot diagrams/${output_name}_focus.dot -Tpng -o diagrams/${output_name}_focus.png
#   else
#     echo "Skipping $file"
#   fi
# done

cd ..
tar --exclude='tmp/*' --exclude='`pwd`/gems/*' -zcf $CHAPTER-`date +%Y%m%d%H%M%S`.tgz sportsball; echo "zipping done"