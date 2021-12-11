module PredictionUi
  def self.configure(predictor)
    @predictor = predictor
    freeze
  end

  def self.predictor
    @predictor
  end
end

