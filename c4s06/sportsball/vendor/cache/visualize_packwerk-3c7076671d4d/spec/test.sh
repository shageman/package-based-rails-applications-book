set -x
set -e

cd sample_app1
bundle

bundle exec visualize_packs --help

# Usage: visualize_packs [options]
#         --no-layers                  Don't show architectural layers
#         --no-dependencies            Don't show accepted dependencies
#         --no-todos                   Don't show package todos
#         --no-privacy                 Don't show privacy enforcement
#         --no-teams                   Don't show team colors
#         --focus-on=PACKAGE           Don't show privacy enforcement
#         --only-edges-to-focus        If focus is set, this shows only the edges to/from the focus node instead of all edges in the focussed graph. This only has effect when --focus-on is set.
#         --remote-base-url=PACKAGE    Link package nodes to an URL (affects graphviz SVG generation)
#     -h, --help                       Show this message

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app > tests/plain_new.dot && dot tests/plain_new.dot -Tpng -o tests/plain_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-layers > tests/no_layers_new.dot && dot tests/no_layers_new.dot -Tpng -o tests/no_layers_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-dependencies > tests/no_dependencies_new.dot && dot tests/no_dependencies_new.dot -Tpng -o tests/no_dependencies_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-todos > tests/no_todos_new.dot && dot tests/no_todos_new.dot -Tpng -o tests/no_todos_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-privacy > tests/no_privacy_new.dot && dot tests/no_privacy_new.dot -Tpng -o tests/no_privacy_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --no-teams > tests/no_teams_new.dot && dot tests/no_teams_new.dot -Tpng -o tests/no_teams_new.png

bundle exec visualize_packs --no-dependencies --no-todos --no-privacy --no-teams > tests/only_layers_new.dot && dot tests/only_layers_new.dot -Tpng -o tests/only_layers_new.png
bundle exec visualize_packs --no-layers --no-dependencies --no-todos --no-privacy --no-teams > tests/no_to_all_new.dot && dot tests/no_to_all_new.dot -Tpng -o tests/no_to_all_new.png

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=. > tests/focussed_on_root_new.dot && dot tests/focussed_on_root_new.dot -Tpng -o tests/focussed_on_root_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/ui > tests/focussed_on_packs_ui_new.dot && dot tests/focussed_on_packs_ui_new.dot -Tpng -o tests/focussed_on_packs_ui_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/models > tests/focussed_on_packs_model_new.dot && dot tests/focussed_on_packs_model_new.dot -Tpng -o tests/focussed_on_packs_model_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/utility > tests/focussed_on_packs_utility_new.dot && dot tests/focussed_on_packs_utility_new.dot -Tpng -o tests/focussed_on_packs_utility_new.png

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=. --only-edges-to-focus > tests/focussed_on_root_focus_edges_new.dot && dot tests/focussed_on_root_focus_edges_new.dot -Tpng -o tests/focussed_on_root_focus_edges_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/ui --only-edges-to-focus > tests/focussed_on_packs_ui_focus_edges_new.dot && dot tests/focussed_on_packs_ui_focus_edges_new.dot -Tpng -o tests/focussed_on_packs_ui_focus_edges_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/models --only-edges-to-focus > tests/focussed_on_packs_model_focus_edges_new.dot && dot tests/focussed_on_packs_model_focus_edges_new.dot -Tpng -o tests/focussed_on_packs_model_focus_edges_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_on=packs/utility --only-edges-to-focus > tests/focussed_on_packs_utility_focus_edges_new.dot && dot tests/focussed_on_packs_utility_focus_edges_new.dot -Tpng -o tests/focussed_on_packs_utility_focus_edges_new.png

bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --roll_nested_todos_into_top_level > tests/roll_nested_todos_into_top_level_new.dot && dot tests/roll_nested_todos_into_top_level_new.dot -Tpng -o tests/roll_nested_todos_into_top_level_new.png
bundle exec visualize_packs --remote-base-url=https://github.com/shageman/visualize_packwerk/tree/main/spec/sample_app --focus_folder=packs/model > tests/focus_folder_new.dot && dot tests/focus_folder_new.dot -Tpng -o tests/focus_folder_new.png
