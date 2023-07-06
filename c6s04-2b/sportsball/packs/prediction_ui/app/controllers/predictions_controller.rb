class PredictionsController < ApplicationController
  def new
    @teams = TeamRepository.list
  end

  def create
    predictor = PredictionUi.predictor
    predictor.learn(TeamRepository.list, GameRepository.list)
    @prediction = predictor.predict(
        TeamRepository.get(params["first_team"]["id"].to_i),
        TeamRepository.get(params["second_team"]["id"].to_i))
  end
end