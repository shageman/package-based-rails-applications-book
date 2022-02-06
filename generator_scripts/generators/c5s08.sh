#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step replaces the dependency injection with the service locator pattern.
# Typing a service locator is tricky. So we don't do it here.
#
###############################################################################

rm config/initializers/configure_prediction_ui.rb

rm -rf packages/prediction_ui/app/services

echo '# typed: false
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
' > packages/prediction_ui/app/controllers/predictions_controller.rb

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/games
- packages/rails_shims
- packages/teams
- packages/service_locator
' > packages/prediction_ui/package.yml

echo 'Rails.application.config.to_prepare do
  ServiceLocator.instance.register_service(:predictor, Predictor.new)
end
' > config/initializers/register_services.rb

echo 'enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
' > packages/predictor/package.yml

mkdir -p packages/service_locator/app/public
mkdir -p packages/service_locator/spec

echo 'enforce_dependencies: true
enforce_privacy: true
' > packages/service_locator/package.yml

echo '# typed: true

class ServiceLocator
  include Singleton

  def register_service(name, service)
    @services ||= {}
    @services[name] = service
    puts "Registered service as #{name}"
  end

  def get_service(name)
    @services ||= {}

    raise ServiceNotFoundError, "Service #{name} was never registered" unless @services[name]

    @services[name]
  end
end
' > packages/service_locator/app/public/service_locator.rb

echo '# typed: false
RSpec.describe ServiceLocator do
  subject { described_class.instance }

  describe "when it can be found" do
    it "getting a service raises an error" do
      expect { subject.get_service(:some_service) }.to raise_error(ServiceNotFoundError)
    end
  end

  describe "getting a given service" do
    it "returns that service instance" do
      subject.register_service(:some_set_service, :a)
      expect(subject.get_service(:some_set_service)).to eq(:a)
    end
  end
end
' > packages/service_locator/spec/service_locator_spec.rb

echo 'class ServiceNotFoundError < RuntimeError
end
' > packages/service_locator/app/public/service_not_found_error.rb

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
- packages/rails_shims
- packages/teams
' > packages/games/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor_interface
- packages/rails_shims
' > packages/teams/package.yml

echo '
enforce_dependencies: true
enforce_privacy: false
dependencies:
- packages/predictor
- packages/service_locator
' > package.yml
