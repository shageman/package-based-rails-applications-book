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
    game_defaults = {}
    if overrides.has_key?(:first_team)
      game_defaults[:first_team_id] = overrides.delete(:first_team)&.id
    end
    if overrides.has_key?(:second_team)
      game_defaults[:second_team_id] = overrides.delete(:second_team)&.id
    end
    defaults = {
      id: nil,
      first_team_id: -> { create_team.id },
      second_team_id: -> { create_team.id },
      winning_team: 2,
      first_team_score: 2,
      second_team_score: 3,
      location: "Somewhere",
      date: Date.today
    }.merge(game_defaults)
    evaluate(defaults.merge(overrides))
  end

  def new_game(overrides = {})
    a = game_params(overrides)
    Game.new(
      a[:id],
      TeamRepository.get(a[:first_team_id]),
      TeamRepository.get(a[:second_team_id]),
      a[:winning_team],
      a[:first_team_score],
      a[:second_team_score],
      a[:location],
      a[:date]
    )
  end

  def create_game(overrides = {})
    game = GameRepository.add(new_game(overrides))
    Kernel.raise "Game creation failed" unless game.persisted?
    game
  end

  private

  def counter
    @counter ||= 0
    @counter += 1
  end

  def evaluate(attributes)
    attributes.keys.inject({}) do |memo, key|
      memo[key] = attributes[key]
      memo[key] = attributes[key].call if attributes[key].is_a?(Proc)
      memo
    end
  end
end
