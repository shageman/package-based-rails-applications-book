# typed: strict

module ParsePackwerk
  module Extensions
    extend T::Sig

    sig { returns(T::Boolean) }
    def self.all_extensions_installed?
      ParsePackwerk.yml.requires.include?('packwerk-extensions')
    end

    sig { returns(T::Boolean) }
    def self.privacy_extension_installed?
      all_extensions_installed? || ParsePackwerk.yml.requires.include?('packwerk/privacy/checker')
    end
  end

  private_constant :Extensions
end
