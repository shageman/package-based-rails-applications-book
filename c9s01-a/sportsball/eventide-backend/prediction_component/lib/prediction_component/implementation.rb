
require 'eventide/postgres'
require 'consumer/postgres'
require 'try'

require "saulabs/trueskill"

require 'component_host'


module PredictionComponent
  LEAGUE_STREAM_NAME = "league"
  GAME_STREAM_NAME = "game"
  
  class RecordGameCreation
    include Messaging::Message

    attribute :league_id, Numeric

    attribute :game_id, Numeric
    attribute :first_team_id, Numeric
    attribute :second_team_id, Numeric
    attribute :winning_team, Numeric
    attribute :time, String
  end

  class GameCreationRecorded
    include Messaging::Message

    attribute :league_id, Numeric

    attribute :game_id, Numeric
    attribute :first_team_id, Numeric
    attribute :second_team_id, Numeric
    attribute :winning_team, Numeric
    attribute :time, String

    attribute :sequence, Integer
    attribute :processed_time, String
  end


  class TeamStrength
    include Schema::DataStructure

    attribute :team_id, Numeric
    attribute :mean, Numeric, default: -> { 1500 }
    attribute :deviation, Numeric, default: -> { 1000 }

    def update_to(mean, deviation)
      self.mean = mean
      self.deviation = deviation
    end
  end

  class League
    include Schema::DataStructure

    attribute :league_id, Numeric
    attribute :teams
    attribute :sequence, Integer

    def initialize
      self.teams = {}
    end

    def []=(team_id, team_strength)
      self.teams[team_id] = team_strength
    end

    def [](team_id)
      self.teams[team_id] || TeamStrength.new
    end

    def processed?(message_sequence)
      return false if sequence.nil?

      sequence >= message_sequence
    end
  end

  class Projection
    include EntityProjection

    entity_name :league

    apply GameCreationRecorded do |event|

      league.league_id = event.league_id

      first_team = league[event.first_team_id]
      second_team = league[event.second_team_id]

      team1 = [::Saulabs::TrueSkill::Rating.new(first_team.mean, first_team.deviation, 1.0)]
      team2 = [::Saulabs::TrueSkill::Rating.new(second_team.mean, second_team.deviation, 1.0)]

      result = event.winning_team == 1 ? [team1, team2] : [team2, team1]
      graph = ::Saulabs::TrueSkill::FactorGraph.new(result, [1,2])
      graph.update_skills

      ts = TeamStrength.new
      ts.team_id = event.first_team_id
      ts.mean = team1.first.mean
      ts.deviation = team1.first.deviation
      league[event.first_team_id] = ts
      
      ts = TeamStrength.new
      ts.team_id = event.second_team_id
      ts.mean = team2.first.mean
      ts.deviation = team2.first.deviation
      league[event.second_team_id] = ts
    end
  end

  class Store
    include EntityStore

    category LEAGUE_STREAM_NAME
    entity League
    projection Projection
    reader MessageStore::Postgres::Read
  end

  class LeagueHandler
    include Messaging::Handle
    include Messaging::StreamName

    dependency :write, Messaging::Postgres::Write

    def configure
      Messaging::Postgres::Write.configure(self)
    end

    handle RecordGameCreation do |command|
      record_game_creation = RecordGameCreation.follow(command)

      Try.(MessageStore::ExpectedVersion::Error) do
        write.initial(record_game_creation, stream_name(command.game_id, "#{GAME_STREAM_NAME}"))
      end
    end
  end

  class GamesHandler
    include Log::Dependency
    include Messaging::Handle
    include Messaging::StreamName

    dependency :write, Messaging::Postgres::Write
    dependency :clock, Clock::UTC
    dependency :store, Store

    def configure
      Messaging::Postgres::Write.configure(self)
      Clock::UTC.configure(self)
      Store.configure(self)
    end

    category LEAGUE_STREAM_NAME

    handle RecordGameCreation do |command|
      league_id = command.league_id
      league, version = store.fetch(league_id, include: :version)
      sequence = command.metadata.global_position

      if league.processed?(sequence)
        logger.info(tag: :ignored) { 
          "Command ignored (Command: #{league.message_type}, League ID: #{league_id}, League Sequence: #{league.sequence}, Global Sequence: #{sequence})" 
        }
        return
      end

      time = clock.iso8601

      result_event = GameCreationRecorded.follow(command)
      result_event.processed_time = time
      result_event.sequence = sequence

      stream_name = stream_name(league_id)

      write.(result_event, stream_name, expected_version: version)
    end
  end


  class LeagueConsumer
    include Consumer::Postgres

    handler LeagueHandler
  end

  class GamesConsumer
    include Consumer::Postgres

    handler GamesHandler
  end

  module Component
    def self.call
      league_command_stream_name = "#{LEAGUE_STREAM_NAME}:command"
      LeagueConsumer.start(league_command_stream_name)

      game_command_stream_name = "#{GAME_STREAM_NAME}"
      GamesConsumer.start(game_command_stream_name)
    end
  end
end