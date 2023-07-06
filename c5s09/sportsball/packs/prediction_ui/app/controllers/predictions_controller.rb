# typed: false

require "ostruct"

class PredictionsController < ApplicationController
  def new
    @teams = Team.all
    @prediction_request = OpenStruct.new(id: SecureRandom.uuid)
  end

  def create
    ActiveSupport::Notifications.instrument("prediction_needed", { 
      current_user: current_user,
      prediction_request_id: params["prediction_request"]["id"],
      team_1_id: params["first_team"]["id"],
      team_1_name: Team.find(params["first_team"]["id"]).name,
      team_2_id: params["second_team"]["id"],
      team_2_name: Team.find(params["second_team"]["id"]).name
    } ) do
    end
  end
end

