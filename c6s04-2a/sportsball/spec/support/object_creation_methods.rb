# typed: true
module ObjectCreationMethods
  def team_params(overrides = {})
    defaults = {
      id: nil,
      name: "Some name #{counter}"
    }
    defaults.merge(overrides)
  end

  def new_team(overrides = {})
    a = team_params(overrides)
    Team.new(a[:id], a[:name])
  end

  def create_team(overrides = {})
    team = TeamRepository.add(new_team(overrides))
    Kernel.raise "Team creation failed" unless team.persisted?
    team
  end

  def game_params(overrides = {})
    defaults = {
      first_team_id: -> { create_team.id },
      second_team_id: -> { create_team.id },
      winning_team: 2,
      first_team_score: 2,
      second_team_score: 3,
      location: "Somewhere",
      date: Date.today
    }
    defaults.merge(overrides)
  end

  def new_game(overrides = {})
    Game.new { |game| apply(game, game_params(overrides), {}) }
  end

  def create_game(overrides = {})
    new_game(overrides).tap(&:save!)
  end

  private

  def counter
    @counter ||= 0
    @counter += 1
  end

  def apply(object, defaults, overrides)
    options = defaults.merge(overrides)
    options.each do |method, value_or_proc|
      object.__send__(
          "#{method}=",
          value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
    end
  end
end

