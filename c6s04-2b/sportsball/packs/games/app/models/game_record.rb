# typed: strict
class GameRecord < ApplicationRecord
  self.table_name = "games"
  include HistoricalPerformanceIndicator
  extend T::Sig
  validates :date, :location, :first_team_id, :second_team_id, :winning_team,
            :first_team_score, :second_team_score, presence: true

  sig { returns(T.nilable(Integer)).override }
  def first_team_id
    self[:first_team_id]
  end

  sig { returns(T.nilable(Integer)).override }
  def second_team_id
    self[:second_team_id]
  end

  sig { returns(T.nilable(Integer)).override }
  def winning_team
    self[:winning_team]
  end
end
