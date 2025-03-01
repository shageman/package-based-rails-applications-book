# typed: strict
module Predictor
  class Prediction
    extend T::Sig

    sig { returns(Contender) }
    attr_reader :first_team

    sig { returns(Contender) }
    attr_reader :second_team

    sig { returns(Contender) }
    attr_reader :winner
  
    sig { params(first_team: Contender, second_team: Contender, winner: Contender).void }
    def initialize(first_team, second_team, winner)
      @first_team = T.let(first_team, Contender)
      @second_team = T.let(second_team, Contender)
      @winner = T.let(winner, Contender)
    end
  end
end
