# typed: true
class Team
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  include Contender
  extend T::Sig

  validates :name, presence: true

  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def persisted?
    !!id
  end

  def to_hash
    { id: id, name: name}
  end

  def ==(other)
    id == other.id && name == other.name
  end
end

