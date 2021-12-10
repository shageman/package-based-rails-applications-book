# typed: strict

module PredictionUi
  extend T::Sig

  sig {params(predictor: Predictor).void}
  def self.configure(predictor)
    @predictor = T.let(predictor, T.nilable(Predictor))
    freeze
  end

  sig {returns(T.nilable(Predictor))}
  def self.predictor
    @predictor
  end
end

