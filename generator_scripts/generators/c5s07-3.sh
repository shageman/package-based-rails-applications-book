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

sed -i '/Packs\/TypedPublicApis/,+2d' packs/predictor/package_rubocop.yml
echo '
Packs/TypedPublicApis:
  Enabled: true' >> packs/predictor/package_rubocop.yml


mkdir -p packs/predictor_interface/app/public/predictor

mv packs/predictor/app/models/predictor/prediction.rb packs/predictor_interface/app/public/predictor/prediction.rb

sed -i 's/Predictor::Predictor/PredictorInterface/g' packs/prediction_ui/app/services/prediction_ui.rb


echo '# typed: strict

module PredictorInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void }
  def learn(teams, games); end

  sig { abstract.params(first_team: Contender, second_team: Contender).returns(Predictor::Prediction) }
  def predict(first_team, second_team); end
end
' > packs/predictor_interface/app/public/predictor_interface.rb

echo '# typed: strict

module Contender
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(Integer) }
  def id; end
end
' > packs/predictor_interface/app/public/contender.rb

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
' > packs/predictor_interface/app/public/historical_performance_indicator.rb



sed -i "1i # typed: strict" packs/predictor/app/public/predictor/predictor.rb
sed -i '/class Predictor/a\    include PredictorInterface\
    extend T::Sig' packs/predictor/app/public/predictor/predictor.rb

sed -i '/def learn/s/^/    sig {override.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void}\n/' packs/predictor/app/public/predictor/predictor.rb
sed -i '/def learn/a\      @teams_lookup = T.let({}, T.nilable(T::Hash[Integer, TeamLookup]))' packs/predictor/app/public/predictor/predictor.rb
sed -i '/def predict/s/^/    sig {override.params(first_team: Contender, second_team: Contender).returns(Prediction)}\n/' packs/predictor/app/public/predictor/predictor.rb
sed -i '/def higher_mean_team/s/^/  sig {params(first_team: Contender, second_team: Contender).returns(T::Boolean)}\n/' packs/predictor/app/public/predictor/predictor.rb
sed -i '/private/a\    class TeamLookup < T::Struct\
      const :team, Contender\
      const :rating, ::Saulabs::TrueSkill::Rating\
    end\
    private_constant :TeamLookup' packs/predictor/app/public/predictor/predictor.rb
sed -i 's/@teams_lookup\[first_team.id\]/T.must(T.must(@teams_lookup)[first_team.id])/g' packs/predictor/app/public/predictor/predictor.rb
sed -i 's/@teams_lookup\[second_team.id\]/T.must(T.must(@teams_lookup)[second_team.id])/g' packs/predictor/app/public/predictor/predictor.rb
sed -i 's/\[:team\]/.team/g' packs/predictor/app/public/predictor/predictor.rb
sed -i 's/\[:rating\]/.rating/g' packs/predictor/app/public/predictor/predictor.rb
sed -i '/memo\[team.id\] =/,+4d' packs/predictor/app/public/predictor/predictor.rb
sed -i '/teams.inject/a\        memo[team.id] = TeamLookup.new(\
          team: team,\
          rating: ::Saulabs::TrueSkill::Rating.new(1500.0, 1000.0, 1.0)\
        )\
        memo' packs/predictor/app/public/predictor/predictor.rb

cat packs/predictor/app/public/predictor/predictor.rb

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

echo 'Packs/RootNamespaceIsPackName: 
  Enabled: false' > packs/games/package_rubocop.yml

echo 'Packs/RootNamespaceIsPackName: 
  Enabled: false' > packs/games_admin/package_rubocop.yml

echo 'Packs/RootNamespaceIsPackName: 
  Enabled: false

Packs/DocumentedPublicApis:
  Enabled: false

Packs/ClassMethodsAsPublicApis:
  Enabled: false
' > packs/predictor_interface/package_rubocop.yml

echo 'Packs/RootNamespaceIsPackName: 
  Enabled: false' > packs/rails_shims/package_rubocop.yml