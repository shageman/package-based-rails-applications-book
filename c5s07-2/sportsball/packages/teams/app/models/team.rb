# typed: false
class Team < ApplicationRecord
  validates :name, presence: true
end
