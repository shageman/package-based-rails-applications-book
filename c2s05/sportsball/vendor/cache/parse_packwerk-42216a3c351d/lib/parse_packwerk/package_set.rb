# typed: strict
# frozen_string_literal: true

require "pathname"
require 'bundler'

module ParsePackwerk
  class PackageSet
    extend T::Sig

    sig { params(package_pathspec: T::Array[String], exclude_pathspec: T::Array[String]).returns(T::Array[Package]) }
    def self.from(package_pathspec:, exclude_pathspec:)
      package_glob_patterns = package_pathspec.map do |pathspec|
        File.join(pathspec, PACKAGE_YML_NAME)
      end

      # The T.unsafe is because the upstream RBI is wrong for Pathname.glob
      package_paths = T.unsafe(Pathname).glob(package_glob_patterns)
        .map(&:cleanpath)
        .reject { |path| exclude_path?(exclude_pathspec, path) }

      package_paths.uniq.map do |path|
        Package.from(path)
      end
    end

    sig { params(globs: T::Array[String], path: Pathname).returns(T::Boolean) }
    def self.exclude_path?(globs, path)
      globs.any? do |glob|
        path.fnmatch(glob, File::FNM_EXTGLOB)
      end
    end

    private_class_method :exclude_path?
  end
end
