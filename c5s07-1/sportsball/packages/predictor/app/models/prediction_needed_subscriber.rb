class PredictionNeededSubscriber
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

