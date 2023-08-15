# typed: strict

module HistoricalPerformanceIndicator
  extend T::Sig
  extend T::Helpers
  interface!

  # Identifier of the first team playing
  sig { abstract.returns(T.nilable(Integer)) }
  def first_team_id; end

  # Identifier of the second team playing
  sig { abstract.returns(T.nilable(Integer)) }
  def second_team_id; end

  # 1: first team won. 2: second team won. No draws.
  sig { abstract.returns(T.nilable(Integer)) }
  def winning_team; end
end

