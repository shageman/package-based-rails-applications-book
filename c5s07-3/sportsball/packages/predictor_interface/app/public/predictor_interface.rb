# typed: strict

module PredictorInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(teams: T::Enumerable[Contender], games: T::Enumerable[HistoricalPerformanceIndicator]).void }
  def learn(teams, games); end

  sig { abstract.params(first_team: Contender, second_team: Contender).returns(Prediction) }
  def predict(first_team, second_team); end
end

