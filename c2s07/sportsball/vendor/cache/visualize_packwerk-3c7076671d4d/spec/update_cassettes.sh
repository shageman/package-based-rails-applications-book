set -x
set -e

cd sample_app1
bundle

rm -f tests/*.dot
rm -f tests/*.png

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app > tests/plain.dot && dot tests/plain.dot -Tpng -o tests/plain.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-layers > tests/no_layers.dot && dot tests/no_layers.dot -Tpng -o tests/no_layers.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-dependencies > tests/no_dependencies.dot && dot tests/no_dependencies.dot -Tpng -o tests/no_dependencies.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-todos > tests/no_todos.dot && dot tests/no_todos.dot -Tpng -o tests/no_todos.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-privacy > tests/no_privacy.dot && dot tests/no_privacy.dot -Tpng -o tests/no_privacy.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-teams > tests/no_teams.dot && dot tests/no_teams.dot -Tpng -o tests/no_teams.png

bundle exec visualize_packs --no-dependencies --no-todos --no-privacy --no-teams > tests/only_layers.dot && dot tests/only_layers.dot -Tpng -o tests/only_layers.png
bundle exec visualize_packs --no-layers --no-dependencies --no-todos --no-privacy --no-teams > tests/no_to_all.dot && dot tests/no_to_all.dot -Tpng -o tests/no_to_all.png

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=. > tests/focussed_on_root.dot && dot tests/focussed_on_root.dot -Tpng -o tests/focussed_on_root.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/ui > tests/focussed_on_packs_ui.dot && dot tests/focussed_on_packs_ui.dot -Tpng -o tests/focussed_on_packs_ui.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/models > tests/focussed_on_packs_model.dot && dot tests/focussed_on_packs_model.dot -Tpng -o tests/focussed_on_packs_model.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/utility > tests/focussed_on_packs_utility.dot && dot tests/focussed_on_packs_utility.dot -Tpng -o tests/focussed_on_packs_utility.png

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=. --only-edges-to-focus > tests/focussed_on_root_focus_edges.dot && dot tests/focussed_on_root_focus_edges.dot -Tpng -o tests/focussed_on_root_focus_edges.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/ui --only-edges-to-focus > tests/focussed_on_packs_ui_focus_edges.dot && dot tests/focussed_on_packs_ui_focus_edges.dot -Tpng -o tests/focussed_on_packs_ui_focus_edges.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/models --only-edges-to-focus > tests/focussed_on_packs_model_focus_edges.dot && dot tests/focussed_on_packs_model_focus_edges.dot -Tpng -o tests/focussed_on_packs_model_focus_edges.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/utility --only-edges-to-focus > tests/focussed_on_packs_utility_focus_edges.dot && dot tests/focussed_on_packs_utility_focus_edges.dot -Tpng -o tests/focussed_on_packs_utility_focus_edges.png

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --roll_nested_todos_into_top_level > tests/roll_nested_todos_into_top_level.dot && dot tests/roll_nested_todos_into_top_level.dot -Tpng -o tests/roll_nested_todos_into_top_level.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_folder=packs/model > tests/focus_folder.dot && dot tests/focus_folder.dot -Tpng -o tests/focus_folder.png

convert \
  tests/plain.png \
  tests/no_layers.png \
  tests/no_dependencies.png \
  tests/no_todos.png \
  tests/no_privacy.png \
  tests/no_teams.png \
  tests/only_layers.png \
  tests/no_to_all.png \
  tests/focussed_on_root.png \
  tests/focussed_on_packs_ui.png \
  tests/focussed_on_packs_model.png \
  tests/focussed_on_packs_utility.png \
  tests/focussed_on_root_focus_edges.png \
  tests/focussed_on_packs_ui_focus_edges.png \
  tests/focussed_on_packs_model_focus_edges.png \
  tests/focussed_on_packs_utility_focus_edges.png \
  -append ../../diagram_examples.png

