Rails.application.config.to_prepare do
  ServiceLocator.instance.register_service(:predictor, Predictor::Predictor.new)
end

