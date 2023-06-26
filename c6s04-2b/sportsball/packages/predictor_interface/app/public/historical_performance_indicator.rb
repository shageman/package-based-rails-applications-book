# typed: strict

module HistoricalPerformanceIndicator
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(T.nilable(Integer)) }
  def first_team_id; end

  sig { abstract.returns(T.nilable(Integer)) }
  def second_team_id; end

  sig { abstract.returns(T.nilable(Integer)) }
  def winning_team; end
end

