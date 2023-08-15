require_relative 'prediction_component/implementation'

component_name = 'league-service'
ComponentHost.start(component_name) do |host|
  host.register(PredictionComponent::Component)
end