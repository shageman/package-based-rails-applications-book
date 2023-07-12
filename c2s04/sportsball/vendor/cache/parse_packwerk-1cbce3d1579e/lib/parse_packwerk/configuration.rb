# typed: strict

module ParsePackwerk
  class Configuration < T::Struct
    extend T::Sig

    const :exclude, T::Array[String]
    const :package_paths, T::Array[String]
    const :requires, T::Array[String]
    const :raw, T::Hash[String, T.untyped]

    sig { returns(Configuration) }
    def self.fetch
      packwerk_yml_filename = Pathname.new(PACKWERK_YML_NAME)
      if !File.exist?(packwerk_yml_filename)
        raw_packwerk_config = {}
      else
        # when the YML file is empty or only contains comment, it gets parsed
        # as the boolean `false` for some reason. this handles that case
        raw_packwerk_config = YAML.load_file(packwerk_yml_filename) || {}
      end

      Configuration.new(
        exclude: excludes(raw_packwerk_config),
        package_paths: package_paths(raw_packwerk_config),
        requires: raw_packwerk_config['require'] || [],
        raw: raw_packwerk_config
      )
    end

    sig { params(config_hash: T::Hash[T.untyped, T.untyped]).returns(T::Array[String]) }
    def self.excludes(config_hash)
      specified_exclude = config_hash['exclude']
      excludes = if specified_exclude.nil?
        DEFAULT_EXCLUDE_GLOBS.dup
      else
        Array(specified_exclude)
      end

      excludes.push Bundler.bundle_path.join("**").to_s
    end

    sig { params(config_hash: T::Hash[T.untyped, T.untyped]).returns(T::Array[String]) }
    def self.package_paths(config_hash)
      specified_package_paths = config_hash['package_paths']
      package_paths = if specified_package_paths.nil?
        DEFAULT_PACKAGE_PATHS.dup
      else
        Array(specified_package_paths)
      end

      # We add the root package path always
      package_paths.push '.'
    end
  end
end
