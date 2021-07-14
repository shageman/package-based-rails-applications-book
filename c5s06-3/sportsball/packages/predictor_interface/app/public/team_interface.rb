# typed: strict

module TeamInterface
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(Integer) }
  def id; end
end

