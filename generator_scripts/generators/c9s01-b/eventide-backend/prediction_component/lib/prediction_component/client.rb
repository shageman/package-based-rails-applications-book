require_relative 'implementation'

module PredictionComponent
  module Client
    module RecordGameCreation
      def self.call(
        game_id: random_id, 
        first_team_id: random_id, 
        second_team_id: random_id, 
        winning_team: 1
      )
        game = PredictionComponent::RecordGameCreation.new

        game.game_id = game_id
        game.first_team_id = first_team_id
        game.second_team_id = second_team_id
        game.winning_team = winning_team

        game.time = Time.now.iso8601

        stream_name = Messaging::StreamName.command_stream_name(game_id, GAME_STREAM_NAME)
        Messaging::Postgres::Write.(game, stream_name)
      end

      private

      def self.random_id
        rand(1_000_000_000)
      end
    end

    module FetchTeamStrength
      def self.call(team_id = random_id, inclusion = nil)
        team, version = Store.build.fetch(team_id, include: :version)
        inclusion == { include: :version } ? [team, version] : team
      end
    end
  end
end