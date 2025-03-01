module HanamiPredictor
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

