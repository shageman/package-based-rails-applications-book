# typed: false
class GameRecord < ApplicationRecord
  self.table_name = "games"

  include HistoricalPerformanceIndicator
  extend T::Sig

  validates :date, :location, :first_team_id, :second_team_id, :winning_team,
            :first_team_score, :second_team_score, presence: true
end

