Rails.application.config.to_prepare do
  PredictionUi.configure(Predictor::Predictor.new)
end

