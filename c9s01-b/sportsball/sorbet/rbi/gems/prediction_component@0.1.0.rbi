module PredictionComponent
  module Client
    class RecordGameCreation
      def self.call(game_id = T.unsafe(nil), first_team_id = T.unsafe(nil), second_team_id = T.unsafe(nil), winning_team = T.unsafe(nil)); end
    end

    class FetchTeamStrength
      def self.cal(team_id = T.unsafe(nil), inclusion = T.unsafe(nil)); end
    end

    class FetchLeague
      def self.call(inclusion = T.unsafe(nil)); end
    end
  end
end
