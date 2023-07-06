# typed: strict
module PredictionUi
  extend T::Sig
  sig {params(predictor: Predictor::Predictor).void}
  def self.configure(predictor)
    @predictor = T.let(predictor, T.nilable(Predictor::Predictor))
  end

  sig {returns(T.nilable(Predictor::Predictor))}
  def self.predictor
    @predictor
  end
end

