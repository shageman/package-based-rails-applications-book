# typed: strict

module Contender
  extend T::Sig
  extend T::Helpers
  interface!

  # Identifier of a contender
  sig { abstract.returns(Integer) }
  def id; end
end

