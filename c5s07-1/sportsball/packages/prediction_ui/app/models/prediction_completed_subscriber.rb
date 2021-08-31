class PredictionCompletedSubscriber
  def self.configure
    ActiveSupport::Notifications.subscribe("prediction_completed") do |name, start, finish, id, payload|
      PredictionChannel.broadcast_to(payload[:current_user], **payload)  
    end
  end
end

