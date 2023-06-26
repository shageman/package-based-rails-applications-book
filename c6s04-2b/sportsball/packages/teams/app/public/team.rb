# typed: strict
class Team
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  include Contender
  extend T::Sig

  validates :name, presence: true

  sig { returns(T.nilable(Integer)).override }
  attr_reader :id

  sig { returns(T.nilable(String)) }
  attr_reader :name

  sig { params(id: T.nilable(Integer), name: T.nilable(String)).void }
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

  sig { returns(Integer) }
  def hash
    [id, name].hash
  end

  sig { params(other: T::untyped).returns(T::Boolean) }
  def ==(other)
    eql?(other)
  end

  sig { params(other: T::untyped).returns(T::Boolean) }
  def eql?(other)
    self.class == other.class &&
      self.id == other.id && self.name == other.name
  end
end

