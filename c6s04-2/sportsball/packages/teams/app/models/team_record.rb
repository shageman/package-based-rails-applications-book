# typed: false
class TeamRecord < ApplicationRecord
  self.table_name = "teams"

  include Contender
  extend T::Sig

  validates :name, presence: true
end

