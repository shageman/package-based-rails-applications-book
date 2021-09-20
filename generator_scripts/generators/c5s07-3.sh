#!/bin/bash

set -v
set -x
set -e

mkdir -p packages/prediction_events/app/public/prediction_events/

echo '' > packages/prediction_events/app/public/prediction_events/prediction_needed_event.rb
echo '' > packages/prediction_events/app/public/prediction_events/prediction_completed_event.rb

echo '' > packages/prediction_events/app/public/prediction_events/prediction_completed_event.rb

echo '' > packages/prediction_events/package.yml

echo 'class PredictionNeededSubscriber
  def self.configure
    ActiveSupport::Notifications.subscribe("prediction_needed") do |name, start, finish, id, payload|
      predictor = Predictor.new(Team.all)
      predictor.learn(Game.all)
      prediction = predictor.predict(
        Team.find(payload[:team_1_id]),
        Team.find(payload[:team_2_id])
      )

      new_payload = payload.merge(winning_team_name: prediction.winner.name)
      ActiveSupport::Notifications.instrument("prediction_completed", new_payload) do
      end  
    end
  end
end
' > packages/prediction_needed_subscriber/app/public/prediction_needed_subscriber.rb

echo '' > packages/prediction_needed_subscriber/package.yml

echo 'class PredictionCompletedSubscriber
  def self.configure
    ActiveSupport::Notifications.subscribe("prediction_completed") do |name, start, finish, id, payload|
      PredictionChannel.broadcast_to(payload[:current_user], **payload)  
    end
  end
end
' > packages/prediction_ui/app/models/pprediction_completed_subscriber.rb

echo '# typed: false

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
' > packages/prediction_ui/app/controllers/predictions_controller.rb

echo '' > packages/prediction_ui/package.yml

echo '' > packwerk.yml
