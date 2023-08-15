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

sed -i '/Packs\/TypedPublicApis/,+2d' packs/predictor/.rubocop.yml
echo '
Packs/TypedPublicApis:
  Enabled: true' >> packs/predictor/.rubocop.yml


mkdir -p packs/predictor_interface/app/public/predictor
mv packs/predictor/app/models/predictor/prediction.rb packs/predictor_interface/app/public/predictor/prediction.rb
sed -i "1i # typed: strict" packs/predictor_interface/app/public/predictor/prediction.rb
sed -i '/attr_reader/c\    extend T::Sig\
\
    sig { returns(Contender) }\
    attr_reader :first_team\
\
    sig { returns(Contender) }\
    attr_reader :second_team\
\
    sig { returns(Contender) }\
    attr_reader :winner' packs/predictor_interface/app/public/predictor/prediction.rb

sed -i "s/ = first_team/ = T.let(first_team, Contender)/" packs/predictor_interface/app/public/predictor/prediction.rb
sed -i "s/ = second_team/ = T.let(second_team, Contender)/" packs/predictor_interface/app/public/predictor/prediction.rb
sed -i "s/ = winner/ = T.let(winner, Contender)/" packs/predictor_interface/app/public/predictor/prediction.rb
sed -i "/def initialize/i\    sig { params(first_team: Contender, second_team: Contender, winner: Contender).void }
" packs/predictor_interface/app/public/predictor/prediction.rb


sed -i 's/Predictor::Predictor/PredictorInterface/g' packs/prediction_ui/app/services/prediction_ui.rb


echo '# typed: strict

module PredictorInterface
  extend T::Sig
  extend T::Helpers
  interface!

  # Implementation uses this method to learn relative team strengths based on past games.
  # Ensure that all teams are in the teams list if they participate in any games. Otherwise you will get a runtime error
  sig { abstract.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void }
  def learn(teams, games); end

  # Implementation uses this method to predict the outcome of a game between two teams it has previously trained on.
  # Ensure that all teams are in the teams list if they participate in any games. Otherwise you will get a runtime error
  sig { abstract.params(first_team: Contender, second_team: Contender).returns(Predictor::Prediction) }
  def predict(first_team, second_team); end
end
' > packs/predictor_interface/app/public/predictor_interface.rb

echo '# typed: strict

module Contender
  extend T::Sig
  extend T::Helpers
  interface!

  # Identifier of a contender
  sig { abstract.returns(Integer) }
  def id; end
end
' > packs/predictor_interface/app/public/contender.rb

echo '# typed: strict

module HistoricalPerformanceIndicator
  extend T::Sig
  extend T::Helpers
  interface!

  # Identifier of the first team playing
  sig { abstract.returns(Integer) }
  def first_team_id; end

  # Identifier of the second team playing
  sig { abstract.returns(Integer) }
  def second_team_id; end

  # 1: first team won. 2: second team won. No draws.
  sig { abstract.returns(Integer) }
  def winning_team; end
end
' > packs/predictor_interface/app/public/historical_performance_indicator.rb


mkdir -p packs/predictor/app/models/predictor/
mv packs/predictor/app/public/predictor/predictor.rb packs/predictor/app/models/predictor/predictor_impl.rb
sed -i 's/class Predictor/class PredictorImpl/' packs/predictor/app/models/predictor/predictor_impl.rb

echo packs/predictor/app/models/predictor/predictor_impl.rb

echo "# typed: strict
  
module Predictor
  class Predictor
    include PredictorInterface
    extend T::Sig

    sig {void}
    def initialize
      @predictor = T.let(PredictorImpl.new, PredictorImpl)
    end

    # Pass in a list of teams and the games that they played against each other to learn relative team strengths
    # Ensure that all teams are in the teams list if they participate in any games. Otherwise you will get a runtime error
    sig {override.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void}
    def learn(teams, games)
      @predictor.learn(teams, games)
    end
  
    # Pass in two teams to predict the outcome of their next game based on their learned relative team strengths
    sig {override.params(first_team: Contender, second_team: Contender).returns(Prediction)}
    def predict(first_team, second_team)
      @predictor.predict(first_team, second_team)
    end
  end
end
" > packs/predictor/app/public/predictor/predictor.rb

sed -i "1i # typed: strict" packs/teams/app/models/team.rb
sed -i '/class Team/a\  include Contender\
  extend T::Sig' packs/teams/app/models/team.rb



echo '# typed: strict

class Game
  sig { returns(T.nilable(Integer)) }
  def first_team_id; end

  sig { returns(T.nilable(Integer)) }
  def second_team_id; end

  sig { returns(T.nilable(Integer)) }
  def winning_team; end
end
' > packs/games/app/models/game.rbi


sed -i "1i # typed: strict" packs/games/app/models/game.rb
sed -i '/class Game/a\  include HistoricalPerformanceIndicator\
  extend T::Sig' packs/games/app/models/game.rb

bundle install --local


echo "enforce_dependencies: true
enforce_architecture: true
layer: utility
enforce_privacy: true" > packs/predictor_interface/package.yml

bin/packs add_dependency packs/predictor packs/predictor_interface
bin/packs add_dependency packs/teams packs/predictor_interface
bin/packs add_dependency packs/games packs/predictor_interface
bin/packs add_dependency packs/games packs/predictor_interface
bin/packs add_dependency packs/prediction_ui packs/predictor_interface


### !!!!!
# No idea why all these rubocop configs are needed only now...
### !!!!!

echo 'inherit_from: ../../.rubocop.yml
Packs/ClassMethodsAsPublicApis:
  Enabled: false
' > packs/predictor_interface/.rubocop.yml

