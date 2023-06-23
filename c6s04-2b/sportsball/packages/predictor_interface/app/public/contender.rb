# typed: strict

module Contender
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(T.nilable(Integer)) }
  def id; end
end

