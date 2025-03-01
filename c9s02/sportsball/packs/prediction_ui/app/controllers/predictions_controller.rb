
# typed: ignore
class PredictionsController < ApplicationController
  include Dry::Monads[:result]
  
  def new
    @teams = Team.all
  end

  def create
    predictor = HanamiPredictor::Slice["operations.create_prediction"]
    result = predictor.(
      Team.all,
      Game.all,
      HanamiPredictor::Structs::Prediction.new(
        Team.find(params["first_team"]["id"]),
        Team.find(params["second_team"]["id"]),
        nil
      )
    )

    case result
    in Success(prediction)
      @prediction = prediction
    in Failure[:invalid, validation]
      response.text "Invalid prediction"
    end
  end
end

