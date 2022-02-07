# typed: true
class Game
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  # include HistoricalPerformanceIndicator
  # extend T::Sig

  validates :date, :location, :first_team, :second_team, :winning_team,
            :first_team_score, :second_team_score, presence: true

  attr_reader :id
  attr_accessor :first_team,
    :second_team,
    :winning_team,
    :first_team_score,
    :second_team_score,
    :location,
    :date

  def initialize(
      id,
      first_team,
      second_team,
      winning_team,
      first_team_score,
      second_team_score,
      location,
      date
    )
    @id = id
    @first_team = first_team
    @second_team = second_team
    @winning_team = winning_team
    @first_team_score = first_team_score
    @second_team_score = second_team_score
    @location = location
    @date = date
  end

  def persisted?
    !!id
  end

  def to_hash
    {
      id: @id,
      first_team_id: @first_team.id,
      second_team_id: @second_team.id,
      winning_team: @winning_team,
      first_team_score: @first_team_score,
      second_team_score: @second_team_score,
      location: @location,
      date: @date.to_s
    }
  end

  def ==(other)
    id == other.id &&
      first_team == other.first_team &&
      second_team == other.second_team &&
      winning_team == other.winning_team &&
      first_team_score == other.first_team_score &&
      second_team_score == other.second_team_score &&
      location == other.location &&
      date== other.date
  end

  def first_team_id
    @first_team&.id
  end

  def second_team_id
    @second_team&.id
  end
end

