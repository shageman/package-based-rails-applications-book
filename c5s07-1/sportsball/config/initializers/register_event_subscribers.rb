Rails.application.reloader.to_prepare do
  PredictionNeededSubscriber.configure
  PredictionCompletedSubscriber.configure
end
