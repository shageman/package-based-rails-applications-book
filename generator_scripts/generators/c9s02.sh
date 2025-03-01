#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# move predictor into a hanami slice
#
###############################################################################

echo '--ignore=/slices' >> sorbet/config
echo '--ignore=/tmp' >> sorbet/config
sed -i '1i # typed: ignore' packs/prediction_ui/app/controllers/predictions_controller.rb



echo '
gem "hanami", github: "hanami/hanami", branch: "exclude-more-files-from-zeitwerk"
gem "hanami-view", github: "hanami/view", branch: "exclude-more-files-from-zeitwerk"
gem "hanami-controller"
gem "dry-operation"
' >> Gemfile

bundle update puma
bundle

cd tmp
bundle exec hanami new SportsballHanami
cd sportsball_hanami
bundle exec hanami generate slice HanamiPredictor
mv slices ../..

cd ../..

rm -rf slices/hanami_predictor/db
rm -rf slices/hanami_predictor/relations

mkdir -p slices/hanami_predictor/config

echo '# frozen_string_literal: true

module HanamiPredictor
  class Slice < Hanami::Slice
    autoloader.ignore(File.expand_path(File.join(__dir__, "..", "spec")))
  end
end' > slices/hanami_predictor/config/slice.rb

echo 'module HanamiPredictor
  module Structs
    class Prediction
      attr_reader :first_team
      attr_reader :second_team
      attr_reader :winner
    
      def initialize(first_team, second_team, winner)
        @first_team = first_team
        @second_team = second_team
        @winner = winner
      end
    end
  end
end
' > slices/hanami_predictor/structs/prediction.rb

mkdir -p slices/hanami_predictor/operations

echo '# frozen_string_literal: true

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
' > slices/hanami_predictor/operations/create_prediction.rb

mkdir -p "slices/hanami_predictor/spec/operations"

echo '
RSpec.describe "Predictor Slice" do
  before do
    @team1 = create_team name: "A"
    @team2 = create_team name: "B"

    @predictor = HanamiPredictor::Slice["operations.create_prediction"]
  end

  it "predicts teams that have won in the past to win in the future" do
    game = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 1

    prediction = @predictor.(
      [@team1, @team2], 
      [game], 
      HanamiPredictor::Structs::Prediction.new(@team2, @team1, nil)
    )
    expect(prediction.value!.winner).to eq @team1

    prediction = @predictor.(
      [@team1, @team2], 
      [game], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team2, nil)
    )
    expect(prediction.value!.winner).to eq @team1
  end

  it "changes predictions based on games learned" do
    game1 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 1
    game2 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 2
    game3 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 2

    prediction = @predictor.(
      [@team1, @team2], 
      [game1, game2, game3], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team2, nil)
    )
    expect(prediction.value!).to be_an HanamiPredictor::Structs::Prediction
    expect(prediction.value!.first_team).to eq @team1
    expect(prediction.value!.second_team).to eq @team2
    expect(prediction.value!.winner).to eq @team2
  end

  it "behaves funny when teams are equally strong" do
    prediction = @predictor.(
      [@team1, @team2], 
      [], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team2, nil)
    )
    expect(prediction.value!).to be_an HanamiPredictor::Structs::Prediction
    expect(prediction.value!.first_team).to eq @team1
    expect(prediction.value!.second_team).to eq @team2
    expect(prediction.value!.winner).to eq @team2

    prediction = @predictor.(
      [@team1, @team2], 
      [], 
      HanamiPredictor::Structs::Prediction.new(@team2, @team1, nil)
    )

    expect(prediction).to be_a Dry::Monads::Result::Success
    expect(prediction.value!).to be_an HanamiPredictor::Structs::Prediction
    expect(prediction.value!.first_team).to eq @team2
    expect(prediction.value!.second_team).to eq @team1
    expect(prediction.value!.winner).to eq @team1
  end

  it "can return failures " do
    game1 = create_game first_team_id: @team1.id, second_team_id: @team2.id, winning_team: 1

    prediction = @predictor.(
      [@team1], 
      [game1], 
      HanamiPredictor::Structs::Prediction.new(@team1, @team3, nil)
    )

    expect(prediction).to be_a Dry::Monads::Result::Failure
    expect(prediction.failure?).to be_truthy
    expect(prediction.failure).to eq "Building Strengths: Team 2 not found"
  end
end
' > slices/hanami_predictor/spec/operations/create_prediction_spec.rb

echo '
# typed: ignore
class PredictionsController < ApplicationController
  include Dry::Monads[:result]
  
  def new
    @teams = Team.all
  end

  def create
    predictor = HanamiPredictor::Slice["operations.create_prediction"]
    result = predictor.(
      Team.all,
      Game.all,
      HanamiPredictor::Structs::Prediction.new(
        Team.find(params["first_team"]["id"]),
        Team.find(params["second_team"]["id"]),
        nil
      )
    )

    case result
    in Success(prediction)
      @prediction = prediction
    in Failure[:invalid, validation]
      response.text "Invalid prediction"
    end
  end
end
' > packs/prediction_ui/app/controllers/predictions_controller.rb

echo '# typed: ignore

require "dry/monads"
require "dry/operation"
require "hanami/action"
require "hanami/view"

module SportsballHanami
  class App < Hanami::App
    prepare_container do |container|
      container.autoloader.ignore("app")
    end
  end

  class Action < Hanami::Action
    include Dry::Monads[:result]
  end
end

Hanami.boot

module SportsballHanami
  class View < Hanami::View
  end

  class Operation < Dry::Operation
  end
end

Hanami::View::HTML::StringExtensions.class_eval do
  def html_safe
    ActiveSupport::SafeBuffer.new(self)
  end
end

HanamiPredictor::Slice.boot

# p Hanami.app.slices[:hanami_predictor].keys

' > config/initializers/load_hanami.rb


rm -rf packs/predictor
sed -i '/- packs\/predictor/d' package.yml

rm config/initializers/configure_prediction_ui.rb
sed -i '/$dependencies:/{N;d;}' package.yml



echo 'enforce_layers: strict
enforce_dependencies: strict
layer: utility
' > slices/hanami_predictor/package.yml

sed -i '/package_paths:/a - ./slices/*' packwerk.yml
