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

rm -rf packs/prediction_ui/app/services

sed -i '/predictor =/c\    predictor = ServiceLocator.instance.get_service(:predictor)' packs/prediction_ui/app/controllers/predictions_controller.rb

echo '
enforce_dependencies: true
dependencies:
- packs/games
- packs/rails_shims
- packs/teams
- packs/service_locator
' > packs/prediction_ui/package.yml

echo 'Rails.application.config.to_prepare do
  ServiceLocator.instance.register_service(:predictor, Predictor::Predictor.new)
end
' > config/initializers/register_services.rb

echo 'enforce_dependencies: true
dependencies:
- packs/predictor_interface
' > packs/predictor/package.yml

mkdir -p packs/service_locator/app/public
mkdir -p packs/service_locator/spec

echo 'enforce_dependencies: true
enforce_architecture: true
layer: utility
enforce_privacy: true
' > packs/service_locator/package.yml

echo '
Packs/ClassMethodsAsPublicApis:
  Enabled: false
' > packs/service_locator/package_rubocop.yml

sed -i '/packs\/prediction_ui/c\  - packs/service_locator' package.yml

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
' > packs/service_locator/app/public/service_locator.rb

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
' > packs/service_locator/spec/service_locator_spec.rb

echo 'class ServiceNotFoundError < RuntimeError
end
' > packs/service_locator/app/public/service_not_found_error.rb
