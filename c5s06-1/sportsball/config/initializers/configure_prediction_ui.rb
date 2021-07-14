Rails.application.reloader.to_prepare do
  PredictionUi.configure(Predictor)
end

