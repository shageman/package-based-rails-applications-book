require "saulabs/trueskill"
  
module Predictor
  class PredictorImpl
    # Pass in a list of teams and the games that they played against each other to learn relative team strengths
    # Ensure that all teams are in the teams list if they participate in any games. Otherwise you will get a runtime error
    def learn(teams, games)
      @teams_lookup = teams.inject({}) do |memo, team|
        memo[team.id] = {
            team: team,
            rating: ::Saulabs::TrueSkill::Rating.new(1500.0, 1000.0, 1.0)
        }
        memo
      end
  
      games.each do |game|
        first_team_rating = @teams_lookup[game.first_team_id][:rating]
        second_team_rating = @teams_lookup[game.second_team_id][:rating]
        game_result = game.winning_team == 1 ?
            [[first_team_rating], [second_team_rating]] :
            [[second_team_rating], [first_team_rating]]
        ::Saulabs::TrueSkill::FactorGraph.new(game_result, [1, 2]).update_skills
      end
    end
  
    # Pass in two teams to predict the outcome of their next game based on their learned relative team strengths
    def predict(first_team, second_team)
      team1 = @teams_lookup[first_team.id][:team]
      team2 = @teams_lookup[second_team.id][:team]
      winner = higher_mean_team(first_team, second_team) ? team1 : team2
      Prediction.new(team1, team2, winner)
    end
  
    private
  
    def higher_mean_team(first_team, second_team)
      @teams_lookup[first_team.id][:rating].mean >
          @teams_lookup[second_team.id][:rating].mean
    end
  end
end
