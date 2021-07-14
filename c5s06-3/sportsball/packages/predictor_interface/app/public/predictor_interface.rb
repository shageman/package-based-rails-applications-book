# typed: strict

module PredictorInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(teams: T::Enumerable[TeamInterface], games: T::Enumerable[GameInterface]).void }
  def learn(teams, games); end

  sig { abstract.params(first_team: TeamInterface, second_team: TeamInterface).returns(Prediction) }
  def predict(first_team, second_team); end
end

