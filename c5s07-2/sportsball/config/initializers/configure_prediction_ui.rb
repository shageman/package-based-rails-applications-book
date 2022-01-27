# typed: false
Rails.application.config.to_prepare do
  PredictionUi.configure(Predictor.new)
end

