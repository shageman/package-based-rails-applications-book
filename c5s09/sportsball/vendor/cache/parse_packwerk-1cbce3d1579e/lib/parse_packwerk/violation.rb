# typed: strict

module ParsePackwerk
  class Violation < T::Struct
    extend T::Sig

    const :type, String
    const :to_package_name, String
    const :class_name, String
    const :files, T::Array[String]

    sig { returns(T::Boolean) }
    def dependency?
      type == 'dependency'
    end

    sig { returns(T::Boolean) }
    def privacy?
      type == 'privacy'
    end
  end
end
