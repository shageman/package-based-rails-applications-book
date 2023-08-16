module PredictionComponent
  module Client
    class RecordGameCreation
      def self.call(league_id = T.unsafe(nil), game_id = T.unsafe(nil), first_team_id = T.unsafe(nil), second_team_id = T.unsafe(nil), winning_team = T.unsafe(nil)); end
    end

    class FetchTeamStrength
      def self.cal(league_id = T.unsafe(nil), team_id = T.unsafe(nil), inclusion = T.unsafe(nil)); end
    end

    class FetchLeague
      def self.call(league_id = T.unsafe(nil), inclusion = T.unsafe(nil)); end
    end
  end
end
