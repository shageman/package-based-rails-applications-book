# typed: strict
class Team < ApplicationRecord
  include Contender
  extend T::Sig

  validates :name, presence: true
end

