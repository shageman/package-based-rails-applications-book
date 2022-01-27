# typed: false

require "saulabs/trueskill"

class Predictor
  include PredictorInterface
  extend T::Sig

  sig {override.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void}
  def learn(teams, games)
    @teams_lookup = T.let({}, T.nilable(T::Hash[Integer, TeamLookup]))
    @teams_lookup = teams.inject({}) do |memo, team|
      memo[team.id] = TeamLookup.new(
        team: team,
        rating: Saulabs::TrueSkill::Rating.new(1500.0, 1000.0, 1.0)
      )
      memo
    end

    games.each do |game|
      first_team_rating = @teams_lookup[game.first_team_id].rating
      second_team_rating = @teams_lookup[game.second_team_id].rating
      game_result = game.winning_team == 1 ?
          [[first_team_rating], [second_team_rating]] :
          [[second_team_rating], [first_team_rating]]
        Saulabs::TrueSkill::FactorGraph.new(game_result, [1, 2]).update_skills
    end
  end

  sig {override.params(first_team: Contender, second_team: Contender).returns(Prediction)}
  def predict(first_team, second_team)
    team1 = T.must(T.must(@teams_lookup)[first_team.id]).team
    team2 = T.must(T.must(@teams_lookup)[second_team.id]).team
    winner = higher_mean_team(first_team, second_team) ? team1 : team2
    Prediction.new(team1, team2, winner)
  end

  private

  sig {params(first_team: Contender, second_team: Contender).returns(T::Boolean)}
  def higher_mean_team(first_team, second_team)
    T.must(T.must(@teams_lookup)[first_team.id]).rating.mean >
        T.must(T.must(@teams_lookup)[second_team.id]).rating.mean
  end

  class TeamLookup < T::Struct
    const :team, Contender
    const :rating, Saulabs::TrueSkill::Rating
  end
  private_constant :TeamLookup
end

