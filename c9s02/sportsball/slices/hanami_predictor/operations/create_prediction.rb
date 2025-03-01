# frozen_string_literal: true

require "saulabs/trueskill"

module HanamiPredictor
  module Operations
    class CreatePrediction < HanamiPredictor::Operation
      def call(teams, games, game)
        first_team, second_team = game.first_team, game.second_team

        teams_lookup = step build_teams_lookup(teams)
        teams_lookup = step apply_historic_games(teams_lookup, games)

        team1 = step find_team(teams_lookup, first_team.id)
        team2 = step find_team(teams_lookup, second_team.id)
        winner = step higher_mean_team(teams_lookup, first_team, second_team)
        
        Structs::Prediction.new(team1, team2, winner ? team1 : team2)
      end

      private

      def build_teams_lookup(teams)
        teams_lookup = teams.inject({}) do |memo, team|
          memo[team.id] = {
              team: team,
              rating: ::Saulabs::TrueSkill::Rating.new(1500.0, 1000.0, 1.0)
          }
          memo
        end
        Success(teams_lookup)
      end

      def apply_historic_games(teams_lookup, games)
        games.each do |game|
          first_team_rating = teams_lookup.dig(game.first_team_id, :rating)
          if first_team_rating.nil?
            return Failure("Building Strengths: Team #{game.first_team_id} not found")
          end

          second_team_rating = teams_lookup.dig(game.second_team_id, :rating)
          if second_team_rating.nil?
            return Failure("Building Strengths: Team #{game.second_team_id} not found")
          end

          game_result = game.winning_team == 1 ?
              [[first_team_rating], [second_team_rating]] :
              [[second_team_rating], [first_team_rating]]
          ::Saulabs::TrueSkill::FactorGraph.new(game_result, [1, 2]).update_skills
        end
        Success(teams_lookup)
      end

      def find_team(teams_lookup, team_id)
        team = teams_lookup.dig(team_id, :team)
        return Failure("Predicting: Team #{team_id} not found") if team.nil?
        Success(team)
      end

      def higher_mean_team(teams_lookup, first_team, second_team)
        result = teams_lookup[first_team.id][:rating].mean >
            teams_lookup[second_team.id][:rating].mean
        Success(result)
      end
    end
  end
end

