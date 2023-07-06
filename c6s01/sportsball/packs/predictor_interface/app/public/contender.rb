# typed: strict

module Contender
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(Integer) }
  def id; end
end

