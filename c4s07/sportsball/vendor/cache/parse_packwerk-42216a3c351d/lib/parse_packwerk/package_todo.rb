# typed: strict

module ParsePackwerk
  class PackageTodo < T::Struct
    extend T::Sig

    const :pathname, Pathname
    const :violations, T::Array[Violation]

    sig { params(package: Package).returns(PackageTodo) }
    def self.for(package)
      package_todo_yml_pathname = package.directory.join(PACKAGE_TODO_YML_NAME)
      PackageTodo.from(package_todo_yml_pathname)
    end

    sig { params(pathname: Pathname).returns(PackageTodo) }
    def self.from(pathname)
      if !pathname.exist?
        new(
          pathname: pathname.cleanpath,
          violations: []
        )
      else
        package_todo_loaded_yml = YAML.load_file(pathname)

        all_violations = []
        package_todo_loaded_yml&.each_key do |to_package_name|
          package_todo_per_package = package_todo_loaded_yml[to_package_name]
          package_todo_per_package.each_key do |class_name|
            symbol_usage = package_todo_per_package[class_name]
            files = symbol_usage['files']
            violations = symbol_usage['violations']
            violations.uniq.each do |violation_type|
              all_violations << Violation.new(type: violation_type, to_package_name: to_package_name, class_name: class_name, files: files)
            end
          end
        end

        new(
          pathname: pathname.cleanpath,
          violations: all_violations
        )
      end
    end
  end
end
