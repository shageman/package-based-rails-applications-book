class Options
  attr_accessor :show_layers
  attr_accessor :show_dependencies
  attr_accessor :show_todos
  attr_accessor :show_privacy
  attr_accessor :show_teams

  attr_accessor :show_only_focus_package
  attr_accessor :show_only_edges_to_focus_package

  attr_accessor :remote_base_url

  def initialize
    @show_layers = true
    @show_dependencies = true
    @show_todos = true
    @show_privacy = true
    @show_teams = true

    @show_only_focus_package = nil
    @show_only_edges_to_focus_package = false

    @remote_base_url = nil
  end
end