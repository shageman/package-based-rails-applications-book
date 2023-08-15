# typed: strict
  
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

