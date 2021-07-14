# typed: strict
class Team < ApplicationRecord
  include TeamInterface
  extend T::Sig

  validates :name, presence: true
end

