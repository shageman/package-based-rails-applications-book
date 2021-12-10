# typed: strict

module PredictionUi
  extend T::Sig

  sig {params(predictor: PredictorInterface).void}
  def self.configure(predictor)
    @predictor = T.let(predictor, T.nilable(PredictorInterface))
    # freeze
  end

  sig {returns(T.nilable(PredictorInterface))}
  def self.predictor
    @predictor
  end
end

