#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step changes the interaction between prediction_ui and predictor to use
# events. This leads to two forms of events: within the Rails server there are
# those that request and complete the prediction creation. Between the server 
# and the frontend a websocket connection allows pushing of new predictions 
# into the UI
#
###############################################################################

rm -rf packages/service_locator
rm config/initializers/register_services.rb

rm -rf packages/prediction_ui/app/views/predictions/create.html.slim

mkdir -p app/javascript/channels
mkdir -p packages/prediction_ui/app/channels
mkdir -p packages/prediction_ui/app/models
mkdir -p packages/predictor/app/models

mkdir -p packages/prediction_needed_subscriber/app/public

echo 'import consumer from "./consumer"

consumer.subscriptions.create("PredictionChannel", {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("#predictions")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article>
        <span>
          We predict that in <strong>${data.team_1_name}</strong> vs <strong>${data.team_2_name}</strong>. 
          The winner will be <strong>${data.winning_team_name}</strong>!
        </span>
      </article>
    `
  }
})
' > app/javascript/channels/prediction_channel.js

echo 'Rails.application.reloader.to_prepare do
  PredictionNeededSubscriber.configure
  PredictionCompletedSubscriber.configure
end' > config/initializers/register_event_subscribers.rb

echo 'class PredictionChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end' > packages/prediction_ui/app/channels/prediction_channel.rb

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

echo 'class PredictionCompletedSubscriber
  def self.configure
    ActiveSupport::Notifications.subscribe("prediction_completed") do |name, start, finish, id, payload|
      PredictionChannel.broadcast_to(payload[:current_user], **payload)  
    end
  end
end
' > packages/prediction_ui/app/models/prediction_completed_subscriber.rb

echo 'h1 Predictions

= form_tag prediction_path, method: "post", remote: true do |f|
  .field
    = label_tag :first_team_id
    = collection_select(:first_team, :id, @teams, :id, :name)

  .field
    = label_tag :second_team_id
    = collection_select(:second_team, :id, @teams, :id, :name)

  = hidden_field :prediction_request, :id

  .actions = submit_tag "What is it going to be?", class: "button"

h2 Predictions 
#predictions
' > packages/prediction_ui/app/views/predictions/new.html.slim

echo 'class PredictionNeededSubscriber
  def self.configure
    ActiveSupport::Notifications.subscribe("prediction_needed") do |name, start, finish, id, payload|
      predictor = Predictor.new
      predictor.learn(Team.all, Game.all)
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

echo 'module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = current_user
    end

    def session
      @request.session
    end

    private

    def current_user
      session[:current_user]
    end
  end
end
' > packages/rails_shims/app/channels/application_cable/connection.rb

echo 'class ApplicationController < ActionController::Base
  append_view_path(Dir.glob(Rails.root.join("packages/*/app/views")))

  before_action :ensure_session

  def current_user
    session[:current_user]
  end

  private 
  
  def ensure_session
    session[:current_user] ||= "user_#{SecureRandom.uuid}"
  end
end
' > packages/rails_shims/app/controllers/application_controller.rb

echo 'enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/games
- packages/teams
- packages/predictor
' > packages/prediction_needed_subscriber/package.yml

echo 'enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/games
- packages/rails_shims
- packages/teams
' > packages/prediction_ui/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/prediction_needed_subscriber
- packages/prediction_ui
' > package.yml
