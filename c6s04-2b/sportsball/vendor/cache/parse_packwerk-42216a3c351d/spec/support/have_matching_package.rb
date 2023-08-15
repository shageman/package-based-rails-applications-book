RSpec::Matchers.define(:have_matching_package) do |expected_package, expected_package_todo|
  match do |actual_packages|
    @actual_packages = actual_packages
    @expected_package = expected_package
    @actual_package = actual_packages.find{|actual_package| actual_package.name == expected_package.name}
    @actual_package_todo = @actual_package && ParsePackwerk::PackageTodo.for(@actual_package)
    @hashified_expected = deep_hashify_package(expected_package, expected_package_todo)
    @hashified_actual = deep_hashify_package(@actual_package, @actual_package_todo)
    !@actual_package.nil? && @hashified_expected == @hashified_actual
  end

  description do
    "to have a package named #{expected_package.package_name.inspect} with identical attributes"
  end

  def deep_hashify_package(package, package_todo)
    {
      name: package.name,
      enforce_dependencies: package.enforce_dependencies,
      enforce_privacy: package.enforce_privacy,
      metadata: package.metadata,
      dependencies: package.dependencies.sort,
      package_todo: package_todo.nil? ? {} : {
        pathname: package_todo.pathname.to_s,
        violations: hashify_violations(package_todo.violations)
      }
    }
  end

  def diff_packages
    Hashdiff.best_diff(
      @hashified_actual,
      @hashified_expected,
    )
  end

  failure_message do
    if @actual_package.nil?
      "Could not find package with package name #{expected_package.name}. Could only find packages with names: #{@actual_packages.map(&:name)}"
    else
      <<~FAILURE_MESSAGE
      Expected and actual package #{expected_package.name.inspect} are not equal.
      Here is the JSONified diff of the packages:

      #{diff_packages.ai}
      FAILURE_MESSAGE
    end
  end
end
