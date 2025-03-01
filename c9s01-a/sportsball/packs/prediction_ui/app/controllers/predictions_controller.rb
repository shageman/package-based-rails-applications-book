require 'prediction_component/client'
class PredictionsController < ApplicationController
  def new
    @teams = Team.all
  end

  def create
    team1id = params['first_team']['id']
    team2id = params['second_team']['id']

    team1 = Team.find_by_id(team1id)
    team2 = Team.find_by_id(team2id)

    ts1 = PredictionComponent::Client::FetchTeamStrength.(1, team1.id)
    ts2 = PredictionComponent::Client::FetchTeamStrength.(1, team2.id)

    @prediction = Predictor::Prediction.new(team1, team2, ts1.mean > ts2.mean ? team1 : team2)
  end
end
