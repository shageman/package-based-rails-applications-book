#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# League-based version of the eventide-based event-sourced and CQRS-based prediction engine
#
###############################################################################

../../generator-scripts-repo/generator_scripts/generators/c9s01-base.sh c9s01-a

echo "module PredictionComponent
  module Client
    class RecordGameCreation
      def self.call(league_id = T.unsafe(nil), game_id = T.unsafe(nil), first_team_id = T.unsafe(nil), second_team_id = T.unsafe(nil), winning_team = T.unsafe(nil)); end
    end

    class FetchTeamStrength
      def self.cal(league_id = T.unsafe(nil), team_id = T.unsafe(nil), inclusion = T.unsafe(nil)); end
    end

    class FetchLeague
      def self.call(league_id = T.unsafe(nil), inclusion = T.unsafe(nil)); end
    end
  end
end" > sorbet/rbi/gems/prediction_component@0.1.0.rbi




sed -i "1 i\require 'prediction_component/client' \
" packs/games/app/models/game.rb
sed -i '/belongs_to :second_team/a\ \
  sig { void }\
  def record_game_creation\
    PredictionComponent::Client::RecordGameCreation.(\
      league_id: 1, \
      game_id: self.id, \
      first_team_id: self.first_team_id, \
      second_team_id: self.second_team_id, \
      winning_team: self.winning_team\
    )\
  end' packs/games/app/models/game.rb

cat packs/games/app/models/game.rb




sed -i "1 i\require 'prediction_component/client'" packs/prediction_ui/app/controllers/predictions_controller.rb
sed -i '/def create/,+50d' packs/prediction_ui/app/controllers/predictions_controller.rb
echo "  def create
    team1id = params["first_team"]["id"]
    team2id = params["second_team"]["id"]

    team1 = Team.find_by_id(team1id)
    team2 = Team.find_by_id(team2id)

    ts1 = PredictionComponent::Client::FetchTeamStrength.(1, team1id)
    ts2 = PredictionComponent::Client::FetchTeamStrength.(1, team2id)

    @prediction = Predictor::Prediction.new(team1, team2, ts1.mean > ts2.mean ? team1 : team2)
  end
end" >> packs/prediction_ui/app/controllers/predictions_controller.rb

cat packs/prediction_ui/app/controllers/predictions_controller.rb
