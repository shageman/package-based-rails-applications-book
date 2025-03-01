require 'prediction_component/client' 
# typed: strict
class Game < ApplicationRecord
  include HistoricalPerformanceIndicator
  extend T::Sig
  validates :date, :location, :first_team, :second_team, :winning_team,
            :first_team_score, :second_team_score, presence: true
  belongs_to :first_team, class_name: "Team"
  belongs_to :second_team, class_name: "Team"
 

  after_create :record_game_creation 

  sig { void } 
  def record_game_creation 
    PredictionComponent::Client::RecordGameCreation.( 
      league_id: 1, 
      game_id: self.id, 
      first_team_id: self.first_team_id, 
      second_team_id: self.second_team_id, 
      winning_team: self.winning_team 
    ) 
  end
end
