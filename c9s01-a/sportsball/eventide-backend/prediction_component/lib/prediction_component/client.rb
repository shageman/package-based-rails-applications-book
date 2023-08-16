require_relative 'implementation'

module PredictionComponent
  module Client
    module RecordGameCreation
      def self.call(
        league_id: random_id, 
        game_id: random_id, 
        first_team_id: random_id, 
        second_team_id: random_id, 
        winning_team: 1
      )
        game = PredictionComponent::RecordGameCreation.new

        game.league_id = league_id
        game.game_id = game_id
        game.first_team_id = first_team_id
        game.second_team_id = second_team_id
        game.winning_team = winning_team

        game.time = Time.now.iso8601

        stream_name = Messaging::StreamName.command_stream_name(league_id, LEAGUE_STREAM_NAME)
        Messaging::Postgres::Write.(game, stream_name)
      end

      private

      def self.random_id
        rand(1_000_000_000)
      end
    end

    module FetchLeague
      def self.call(league_id = random_id, inclusion = nil)
        league, version = Store.build.fetch(league_id, include: :version)
        inclusion == { include: :version } ? [league, version] : league
      end
    end

    module FetchTeamStrength
      def self.call(league_id = random_id, team_id = random_id, inclusion = nil)
        league, version = FetchLeague.(league_id, inclusion)
        inclusion == { include: :version } ? [league[team_id], version] : league[team_id]
      end
    end
  end
end