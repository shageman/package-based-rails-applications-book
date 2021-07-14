# typed: false
class PredictionsController < ApplicationController
  def new
    @teams = Team.all
  end

  def create
    predictor = ServiceLocator.instance.get_service(:predictor)

    predictor.learn(Team.all, Game.all)
    @prediction = predictor.predict(
        Team.find(params["first_team"]["id"]),
        Team.find(params["second_team"]["id"]))
  end
end

