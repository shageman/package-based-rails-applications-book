# typed: strict
class Team
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  include Contender
  extend T::Sig

  validates :name, presence: true

  sig {returns(Integer)}
  attr_reader :id

  sig {returns(String)}
  attr_reader :name

  sig { params(id: Integer, name: String).void }
  def initialize(id, name)
    @id = id
    @name = name
  end

  sig { returns(T::Boolean) }
  def persisted?
    !!id
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def to_hash
    { id: id, name: name}
  end

  sig { params(other: T::untyped).returns(T::Boolean) }
  def ==(other)
    id == other.id && name == other.name
  end
end

