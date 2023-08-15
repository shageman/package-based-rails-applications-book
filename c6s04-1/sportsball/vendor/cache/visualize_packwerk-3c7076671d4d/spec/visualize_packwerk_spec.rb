require_relative '../lib/visualize_packwerk'

RSpec.describe "Visualize Packwerk" do
  describe ".all_nested_packages" do
    it "should work" do
      input = %w(. packs/a packs/a/z packs/b packs/b/packs/x packs/b/packs/y)
      expected_output = {
        "packs/a/z" => "packs/a",
        "packs/b/packs/x" => "packs/b",
        "packs/b/packs/y" => "packs/b"
      } 

      expect(VisualizePackwerk.all_nested_packages(input)).to eq(expected_output)
    end

    it "explicitly doesn't handle multiple nestings" do
      input = %w(. packs/a packs/a/b packs/a/b/c)

      expect { VisualizePackwerk.all_nested_packages(input) }.to raise_exception(RuntimeError)
    end
  end

  describe ".remove_nested_packs" do
    it "removes nested packs" do
      top_level_a = ParsePackwerk::Package.new(
        name: "packs/a",
        enforce_dependencies: true,
        enforce_privacy: false,
        public_path: 'app/public',
        metadata: {},
        dependencies: ['packs/b', 'packs/b/nested', 'packs/a/nested'],
        config: {enforce_dependencies: true, enforce_privacy: true},
      )
      allow(top_level_a).to receive(:violations) do
        [
          ParsePackwerk::Violation.new(
            type: 'privacy', 
            to_package_name: "packs/b", 
            class_name: "SomeClass1", 
            files: ["some_file1"]
          ),
          ParsePackwerk::Violation.new(
            type: 'privacy', 
            to_package_name: "packs/b/nested", 
            class_name: "SomeClass2", 
            files: ["some_file2"]
          ),
        ]
      end
      nested_a = ParsePackwerk::Package.new(
        name: "packs/a/nested",
        enforce_dependencies: true,
        enforce_privacy: false,
        public_path: 'app/public',
        metadata: {},
        dependencies: ['packs/a', 'packs/b'],
        config: {enforce_dependencies: true, enforce_privacy: true},
      )
      allow(nested_a).to receive(:violations) do
        [
          ParsePackwerk::Violation.new(
            type: 'privacy', 
            to_package_name: "packs/b", 
            class_name: "SomeClass7", 
            files: ["some_file7"]
          ),
          ParsePackwerk::Violation.new(
            type: 'privacy', 
            to_package_name: "packs/b/nested", 
            class_name: "SomeClass8", 
            files: ["some_file8"]
          ),
        ]
      end

      top_level_b = ParsePackwerk::Package.new(
        name: "packs/b",
        enforce_dependencies: true,
        enforce_privacy: false,
        public_path: 'app/public',
        metadata: {},
        dependencies: ['packs/b/nested'],
        config: {enforce_dependencies: true, enforce_privacy: true},
      )
      allow(top_level_b).to receive(:violations) do
        [
          ParsePackwerk::Violation.new(
            type: 'privacy', 
            to_package_name: "packs/b/nested", 
            class_name: "SomeClass4", 
            files: ["some_file4"]
          ),
        ]
      end

      nested_b = ParsePackwerk::Package.new(
        name: "packs/b/nested",
        enforce_dependencies: true,
        enforce_privacy: false,
        public_path: 'app/public',
        metadata: {},
        dependencies: ['packs/a', 'packs/b'],
        config: {enforce_dependencies: true, enforce_privacy: true},
      )
      allow(nested_b).to receive(:violations) do
        [
          ParsePackwerk::Violation.new(
            type: 'privacy', 
            to_package_name: "packs/a", 
            class_name: "SomeClass5", 
            files: ["some_file5"]
          ),
          ParsePackwerk::Violation.new(
            type: 'privacy', 
            to_package_name: "packs/b", 
            class_name: "SomeClass6", 
            files: ["some_file6"]
          ),
        ]
      end


      result = VisualizePackwerk.remove_nested_packs([top_level_a, top_level_b, nested_a, nested_b])
      expect(result.count).to eq 2

      new_top_level_a = result[0]
      expect(new_top_level_a.name).to eq "packs/a"

      new_top_level_b = result[1]
      expect(new_top_level_b.name).to eq "packs/b"

      expect(new_top_level_a.dependencies).to eq ['packs/b']
      expect(new_top_level_a.violations.map(&:inspect)).to eq [
        ParsePackwerk::Violation.new(
          type: 'privacy', 
          to_package_name: "packs/b", 
          class_name: "SomeClass1", 
          files: ["some_file1"]
        ),
        ParsePackwerk::Violation.new(
          type: 'privacy', 
          to_package_name: "packs/b", ## this is no longer pointing to the nested package!
          class_name: "SomeClass2", 
          files: ["some_file2"]
        ),

        # violations from the nested package

        ParsePackwerk::Violation.new(
          type: 'privacy', 
          to_package_name: "packs/b", 
          class_name: "SomeClass7", 
          files: ["some_file7"]
        ),
        ParsePackwerk::Violation.new(
          type: 'privacy', 
          to_package_name: "packs/b", ## this is no longer pointing to the nested package!
          class_name: "SomeClass8", 
          files: ["some_file8"]
        ),
      ].map(&:inspect)

      expect(new_top_level_b.dependencies).to eq ['packs/a']
      ## this does not include a self reference to packs/b
      ## it does now include the dependency on packs/a from the nested pack

      expect(new_top_level_b.violations.map(&:inspect)).to eq [
        ParsePackwerk::Violation.new(
          type: 'privacy', 
          to_package_name: "packs/a", 
          class_name: "SomeClass5", 
          files: ["some_file5"]
        ),
      ].map(&:inspect)
      ## this does not contain any self-violations
      ## it does include the violation from the nested pack onto a
    end
  end
end