set -x
set -e

convert sample_app1/tests/plain.png sample_app1/tests/plain_new.png +append sample_app1/tests/plain_appened_new.png
convert sample_app1/tests/no_layers.png sample_app1/tests/no_layers_new.png +append sample_app1/tests/no_layers_appened_new.png
convert sample_app1/tests/no_dependencies.png sample_app1/tests/no_dependencies_new.png +append sample_app1/tests/no_dependencies_appened_new.png
convert sample_app1/tests/no_todos.png sample_app1/tests/no_todos_new.png +append sample_app1/tests/no_todos_appened_new.png
convert sample_app1/tests/no_privacy.png sample_app1/tests/no_privacy_new.png +append sample_app1/tests/no_privacy_appened_new.png
convert sample_app1/tests/no_teams.png sample_app1/tests/no_teams_new.png +append sample_app1/tests/no_teams_appened_new.png

convert sample_app1/tests/only_layers.png sample_app1/tests/only_layers_new.png +append sample_app1/tests/only_layers_appened_new.png
convert sample_app1/tests/no_to_all.png sample_app1/tests/no_to_all_new.png +append sample_app1/tests/no_to_all_appened_new.png

convert sample_app1/tests/focussed_on_root.png sample_app1/tests/focussed_on_root_new.png +append sample_app1/tests/focussed_on_root_appened_new.png
convert sample_app1/tests/focussed_on_packs_ui.png sample_app1/tests/focussed_on_packs_ui_new.png +append sample_app1/tests/focussed_on_packs_ui_appened_new.png
convert sample_app1/tests/focussed_on_packs_model.png sample_app1/tests/focussed_on_packs_model_new.png +append sample_app1/tests/focussed_on_packs_model_appened_new.png
convert sample_app1/tests/focussed_on_packs_utility.png sample_app1/tests/focussed_on_packs_utility_new.png +append sample_app1/tests/focussed_on_packs_utility_appened_new.png

convert sample_app1/tests/focussed_on_root_focus_edges.png sample_app1/tests/focussed_on_root_focus_edges_new.png +append sample_app1/tests/focussed_on_root_focus_edges_appened_new.png
convert sample_app1/tests/focussed_on_packs_ui_focus_edges.png sample_app1/tests/focussed_on_packs_ui_focus_edges_new.png +append sample_app1/tests/focussed_on_packs_ui_focus_edges_appened_new.png
convert sample_app1/tests/focussed_on_packs_model_focus_edges.png sample_app1/tests/focussed_on_packs_model_focus_edges_new.png +append sample_app1/tests/focussed_on_packs_model_focus_edges_appened_new.png
convert sample_app1/tests/focussed_on_packs_utility_focus_edges.png sample_app1/tests/focussed_on_packs_utility_focus_edges_new.png +append sample_app1/tests/focussed_on_packs_utility_focus_edges_appened_new.png

convert sample_app1/tests/plain_appened_new.png \
  sample_app1/tests/no_layers_appened_new.png \
  sample_app1/tests/no_dependencies_appened_new.png \
  sample_app1/tests/no_todos_appened_new.png \
  sample_app1/tests/no_privacy_appened_new.png \
  sample_app1/tests/no_teams_appened_new.png \
  sample_app1/tests/only_layers_appened_new.png \
  sample_app1/tests/no_to_all_appened_new.png \
  sample_app1/tests/focussed_on_root_appened_new.png \
  sample_app1/tests/focussed_on_packs_ui_appened_new.png \
  sample_app1/tests/focussed_on_packs_model_appened_new.png \
  sample_app1/tests/focussed_on_packs_utility_appened_new.png \
  sample_app1/tests/focussed_on_root_focus_edges_appened_new.png \
  sample_app1/tests/focussed_on_packs_ui_focus_edges_appened_new.png \
  sample_app1/tests/focussed_on_packs_model_focus_edges_appened_new.png \
  sample_app1/tests/focussed_on_packs_utility_focus_edges_appened_new.png \
 -append sample_app1/tests/all_new.png

open sample_app1/tests/all_new.png