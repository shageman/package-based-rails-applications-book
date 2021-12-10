#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step changes the dependency injection to use an interface instead of the
# concrete class and such removing the previously discovered violations
#
###############################################################################

mkdir -p packages/predictor_interface/app/public

mv packages/predictor/app/models/prediction.rb packages/predictor_interface/app/public/prediction.rb

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

module PredictorInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void }
  def learn(teams, games); end

  sig { abstract.params(first_team: Contender, second_team: Contender).returns(Prediction) }
  def predict(first_team, second_team); end
end
' > packages/predictor_interface/app/public/predictor_interface.rb

echo '# typed: strict

module Contender
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(Integer) }
  def id; end
end
' > packages/predictor_interface/app/public/contender.rb

echo '# typed: strict

module HistoricalPerformanceIndicator
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
' > packages/predictor_interface/app/public/historical_performance_indicator.rb

# RUN EXAMPLE




echo '# typed: strict

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
' > packages/predictor/app/models/predictor.rb

# RUN EXAMPLE




echo '# typed: strict
class Team < ApplicationRecord
  include Contender
  extend T::Sig

  validates :name, presence: true
end
' > packages/teams/app/models/team.rb

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

echo 'class Game < ApplicationRecord
  include HistoricalPerformanceIndicator
  extend T::Sig

  validates :date, :location, :first_team, :second_team, :winning_team,
            :first_team_score, :second_team_score, presence: true
  belongs_to :first_team, class_name: "Team"
  belongs_to :second_team, class_name: "Team"
end
' > packages/games/app/models/game.rb


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
- "spec/support/**/*"

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

echo 'enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
' > packages/predictor/package.yml

echo 'enforce_dependencies: true
enforce_privacy: true
' > packages/predictor_interface/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
- packages/rails_shims
' > packages/teams/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
- packages/rails_shims
- packages/teams
' > packages/games/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/games
- packages/predictor_interface
- packages/rails_shims
- packages/teams
' > packages/prediction_ui/package.yml

sed -i "s/class Saulabs::TrueSkill::Rating/class Saulabs::TrueSkill::Rating < Saulabs::Gauss::Distribution/" sorbet/rbi/hidden-definitions/hidden.rbi
