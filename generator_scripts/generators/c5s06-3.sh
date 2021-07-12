#!/bin/bash

set -v
set -x
set -e

mkdir -p packages/predictor_interface/app/public

echo '# typed: strict
Rails.application.reloader.to_prepare do
  PredictionUi.configure(Predictor.new)
end
' > config/initializers/configure_prediction_ui.rb

echo '# typed: strict

class Game
  sig { returns(T.nilable(Integer)) }
  def first_team_id; end

  sig { returns(T.nilable(Integer)) }
  def second_team_id; end

  sig { returns(T.nilable(Integer)) }
  def winning_team; end
end
' > packages/games/app/models/game.rbi

echo '# typed: false
class PredictionsController < ApplicationController
  def new
    @teams = Team.all
  end

  def create
    PredictionUi.predictor.learn(Team.all, Game.all)
    @prediction = PredictionUi.predictor.predict(
        Team.find(params["first_team"]["id"]),
        Team.find(params["second_team"]["id"]))
  end
end
' > packages/prediction_ui/app/controllers/predictions_controller.rb

echo '# typed: strict

module PredictionUi
  extend T::Sig

  sig {params(predictor: PredictorInterface).void}
  def self.configure(predictor)
    @predictor = T.let(predictor, T.nilable(PredictorInterface))
    # freeze
  end

  sig {returns(T.nilable(PredictorInterface))}
  def self.predictor
    @predictor
  end
end
' > packages/prediction_ui/app/services/prediction_ui.rb

echo '# typed: strict

module PredictionUi
  extend T::Sig

  sig {params(predictor: PredictorInterface).void}
  def self.configure(predictor)
    @predictor = T.let(predictor, T.nilable(PredictorInterface))
    # freeze
  end

  sig {returns(T.nilable(PredictorInterface))}
  def self.predictor
    @predictor
  end
end
' > packages/prediction_ui/app/services/prediction_ui.rb

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/games
- packages/predictor_interface
- packages/rails_shims
- packages/teams
' > packages/prediction_ui/package.yml

echo '# typed: strict

require "saulabs/trueskill"

class TeamLookup < T::Struct
  const :team, TeamInterface
  const :rating, Saulabs::TrueSkill::Rating
end

class Predictor
  include PredictorInterface
  extend T::Sig

  sig {override.params(teams: T::Enumerable[TeamInterface], games: T::Enumerable[GameInterface]).void}
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

  sig {override.params(first_team: TeamInterface, second_team: TeamInterface).returns(Prediction)}
  def predict(first_team, second_team)
    team1 = T.must(T.must(@teams_lookup)[first_team.id]).team
    team2 = T.must(T.must(@teams_lookup)[second_team.id]).team
    winner = higher_mean_team(first_team, second_team) ? team1 : team2
    Prediction.new(team1, team2, winner)
  end

  private

  sig {params(first_team: TeamInterface, second_team: TeamInterface).returns(T::Boolean)}
  def higher_mean_team(first_team, second_team)
    T.must(T.must(@teams_lookup)[first_team.id]).rating.mean >
        T.must(T.must(@teams_lookup)[second_team.id]).rating.mean
  end
end
' > packages/predictor/app/models/predictor.rb

echo '# typed: false
RSpec.describe Predictor do
  before do
    @team1 = create_team name: "A"
    @team2 = create_team name: "B"

    @predictor = Predictor.new
  end

  it "predicts teams that have won in the past to win in the future" do
    game = create_game first_team: @team1, second_team: @team2, winning_team: 1
    @predictor.learn([@team1, @team2], [game])

    prediction = @predictor.predict(@team2, @team1)
    expect(prediction.winner).to eq @team1

    prediction = @predictor.predict(@team1, @team2)
    expect(prediction.winner).to eq @team1
  end

  it "changes predictions based on games learned" do
    game1 = create_game first_team: @team1, second_team: @team2, winning_team: 1
    game2 = create_game first_team: @team1, second_team: @team2, winning_team: 2
    game3 = create_game first_team: @team1, second_team: @team2, winning_team: 2
    @predictor.learn([@team1, @team2], [game1, game2, game3])

    prediction = @predictor.predict(@team1, @team2)
    expect(prediction.winner).to eq @team2
  end

  it "behaves funny when teams are equally strong" do
    @predictor.learn([@team1, @team2], [])

    prediction = @predictor.predict(@team1, @team2)
    expect(prediction).to be_an Prediction
    expect(prediction.first_team).to eq @team1
    expect(prediction.second_team).to eq @team2
    expect(prediction.winner).to eq @team2

    prediction = @predictor.predict(@team2, @team1)
    expect(prediction).to be_an Prediction
    expect(prediction.first_team).to eq @team2
    expect(prediction.second_team).to eq @team1
    expect(prediction.winner).to eq @team1
  end
end
' > packages/predictor/spec/models/predictor_spec.rb

echo 'enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
' > packages/predictor/package.yml

echo '# typed: strict

module GameInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(Integer) }
  def first_team_id; end

  sig { abstract.returns(Integer) }
  def second_team_id; end
  
  sig { abstract.returns(Integer) }
  def winning_team; end
end
' > packages/predictor_interface/app/public/game_interface.rb

mv packages/predictor/app/models/prediction.rb packages/predictor_interface/app/public/prediction.rb

echo '# typed: strict

module PredictorInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(teams: T::Enumerable[TeamInterface], games: T::Enumerable[GameInterface]).void }
  def learn(teams, games); end

  sig { abstract.params(first_team: TeamInterface, second_team: TeamInterface).returns(Prediction) }
  def predict(first_team, second_team); end
end
' > packages/predictor_interface/app/public/predictor_interface.rb

echo '# typed: strict

module TeamInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(Integer) }
  def id; end
end
' > packages/predictor_interface/app/public/team_interface.rb

echo 'enforce_dependencies: true
enforce_privacy: true
' > packages/predictor_interface/package.yml

echo '# typed: strict
class Team < ApplicationRecord
  include TeamInterface
  extend T::Sig

  validates :name, presence: true
end
' > packages/teams/app/models/team.rb

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
- packages/rails_shims
' > packages/teams/package.yml

echo '# See: Setting up the configuration file
# https://github.com/Shopify/packwerk/blob/main/USAGE.md#setting-up-the-configuration-file

# List of patterns for folder paths to include
# include:
# - "**/*.{rb,rake,erb}"

# List of patterns for folder paths to exclude
exclude:
- "{bin,node_modules,script,tmp,vendor}/**/*"
- "vendor/bundle/**/*"
- "**/lib/tasks/**/*.rake"

# Patterns to find package configuration files
# package_paths: "**/"

# List of application load paths
# These load paths were auto generated by Packwerk.
load_paths:
- packages/games_admin/app/controllers
- packages/games_admin/app/views
- packages/games/app/models
- packages/prediction_ui/app/controllers
- packages/prediction_ui/app/helpers
- packages/prediction_ui/app/services
- packages/prediction_ui/app/views
- packages/predictor_interface/app/public
- packages/predictor/app/models
- packages/rails_shims/app/channels
- packages/rails_shims/app/controllers
- packages/rails_shims/app/controllers/concerns
- packages/rails_shims/app/helpers
- packages/rails_shims/app/jobs
- packages/rails_shims/app/mailers
- packages/rails_shims/app/models
- packages/rails_shims/app/models/concerns
- packages/teams_admin/app/controllers
- packages/teams_admin/app/views
- packages/teams/app/models
- packages/welcome_ui/app/controllers
- packages/welcome_ui/app/views

# List of custom associations, if any
# custom_associations:
# - "cache_belongs_to"

# Location of inflections file
# inflections_file: "config/inflections.yml"
' > packwerk.yml

find . -iname 'deprecated_references.yml' -delete

bundle install --local
bin/packwerk update-deprecations
bin/rake pocky:generate[root]