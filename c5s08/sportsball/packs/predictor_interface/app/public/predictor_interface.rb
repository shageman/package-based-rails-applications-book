# typed: strict

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

