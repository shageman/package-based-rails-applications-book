
require 'eventide/postgres'
require 'consumer/postgres'
require 'try'

require "saulabs/trueskill"

require 'component_host'


module PredictionComponent
  TEAM_STRENGTH_STREAM_NAME = "team_strength"
  GAME_STREAM_NAME = "game"
  
  class RecordGameCreation
    include Messaging::Message

    attribute :game_id, Numeric
    attribute :first_team_id, Numeric
    attribute :second_team_id, Numeric
    attribute :winning_team, Numeric
    attribute :time, String
  end

  class RecordGameCreationWithStrengths
    include Messaging::Message

    attribute :game_id, Numeric
    attribute :first_team_id, Numeric
    attribute :second_team_id, Numeric
    attribute :winning_team, Numeric
    attribute :time, String

    attribute :first_team_mean, Numeric
    attribute :first_team_deviation, Numeric

    attribute :second_team_mean, Numeric
    attribute :second_team_deviation, Numeric

    attribute :record_for, Numeric
  end

  class GameCreationRecorded
    include Messaging::Message

    attribute :game_id, Numeric
    attribute :first_team_id, Numeric
    attribute :second_team_id, Numeric
    attribute :winning_team, Numeric
    attribute :time, String

    attribute :first_team_mean, Numeric
    attribute :first_team_deviation, Numeric

    attribute :second_team_mean, Numeric
    attribute :second_team_deviation, Numeric

    attribute :record_for, Numeric

    attribute :sequence, Integer
    attribute :processed_time, String
  end

  class TeamStrength
    include Schema::DataStructure

    attribute :team_id, Numeric
    attribute :mean, Numeric, default: -> { 1500 }
    attribute :deviation, Numeric, default: -> { 1000 }
    attribute :sequence, Integer

    def update_to(team_id, mean, deviation)
      self.team_id = team_id
      self.mean = mean
      self.deviation = deviation
    end

    def processed?(message_sequence)
      return false if sequence.nil?

      sequence >= message_sequence
    end
  end

  class Projection
    include EntityProjection

    entity_name :team_strength

    apply GameCreationRecorded do |event|
      # puts "GameCreationRecorded #{event.game_id}: #{event.first_team_id} vs #{event.second_team_id} (#{event.record_for})"

      team1 = [::Saulabs::TrueSkill::Rating.new(event.first_team_mean, event.first_team_deviation, 1.0)]
      team2 = [::Saulabs::TrueSkill::Rating.new(event.second_team_mean, event.second_team_deviation, 1.0)]

      result = event.winning_team == 1 ? [team1, team2] : [team2, team1]
      graph = ::Saulabs::TrueSkill::FactorGraph.new(result, [1,2])
      graph.update_skills

      ts1 = TeamStrength.new
      ts1.team_id = event.first_team_id
      ts1.mean = team1.first.mean
      ts1.deviation = team1.first.deviation
      
      ts2 = TeamStrength.new
      ts2.team_id = event.second_team_id
      ts2.mean = team2.first.mean
      ts2.deviation = team2.first.deviation

      if event.record_for == 1
        team_strength.update_to(ts1.team_id, ts1.mean, ts1.deviation)
      else
        team_strength.update_to(ts2.team_id, ts2.mean, ts2.deviation)
      end
    end
  end

  class Store
    include EntityStore

    category TEAM_STRENGTH_STREAM_NAME
    entity TeamStrength
    projection Projection
    reader MessageStore::Postgres::Read
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

    category TEAM_STRENGTH_STREAM_NAME

    handle RecordGameCreation do |command|
      # puts "RecordGameCreation #{command.game_id}: #{command.first_team_id} vs #{command.second_team_id}"
      record_game_creation = RecordGameCreationWithStrengths.follow(command)

      first_team = store.fetch(command.first_team_id)
      second_team = store.fetch(command.second_team_id)

      record_game_creation.first_team_mean = first_team.mean
      record_game_creation.first_team_deviation = first_team.deviation
  
      record_game_creation.second_team_mean = second_team.mean
      record_game_creation.second_team_deviation = second_team.deviation
  
      record_game_creation.record_for = 2

      Try.(MessageStore::ExpectedVersion::Error) do
        write.initial(record_game_creation, stream_name([command.game_id, record_game_creation.record_for], "#{GAME_STREAM_NAME}:command"))
      end

      record_game_creation = record_game_creation.dup
      record_game_creation.record_for = 1

      Try.(MessageStore::ExpectedVersion::Error) do
        write.initial(record_game_creation, stream_name([command.game_id, record_game_creation.record_for], "#{GAME_STREAM_NAME}:command"))
      end
    end

    handle RecordGameCreationWithStrengths do |command|
      team_id = command.record_for == 1 ? command.first_team_id : command.second_team_id

      team, version = store.fetch(team_id, include: :version)
      sequence = command.metadata.global_position

      if team.processed?(sequence)
        logger.info(tag: :ignored) { 
          "Command ignored (Command: #{team.message_type}, Team ID: #{team_id}, Team Sequence: #{team.sequence}, Global Sequence: #{sequence})" 
        }
        return
      end

      time = clock.iso8601

      result_event = GameCreationRecorded.follow(command)
      result_event.processed_time = time
      result_event.sequence = sequence

      stream_name = stream_name(team_id)

      write.(result_event, stream_name, expected_version: version)
    end
  end

  class GamesConsumer
    include Consumer::Postgres

    handler GamesHandler
  end

  module Component
    def self.call
      game_command_stream_name = "#{GAME_STREAM_NAME}:command"
      GamesConsumer.start(game_command_stream_name)
    end
  end
end