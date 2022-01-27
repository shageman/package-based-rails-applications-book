# typed: ignore
class PredictionsController < ApplicationController
  def new
    @teams = TeamRepository.list
  end

  def create
    predictor = Predictor.new
    predictor.learn(TeamRepository.list, Game.all)
    @prediction = predictor.predict(
        TeamRepository.get(params["first_team"]["id"]),
        TeamRepository.get(params["second_team"]["id"]))
  end
end

