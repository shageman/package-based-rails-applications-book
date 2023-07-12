# frozen_string_literal: true

RSpec.describe ParsePackwerk do
  before do
    write_packwerk_yml
    ParsePackwerk.bust_cache!
  end

  let(:write_packwerk_yml) do
    write_file('packwerk.yml', <<~YML)
      require:
        - packwerk-extensions
      YML
  end

  def hashify_violations(violations)
    violations.map { |v| hashify_violation(v) }
  end

  def hashify_violation(v)
    {
      type: v.type,
      to_package_name: v.to_package_name,
      class_name: v.to_package_name,
      files: v.files
    }
  end

  subject(:all_packages) do
    ParsePackwerk.all
  end

  describe '.all' do
    context 'in empty app' do
      it { is_expected.to be_empty }
    end

    context 'in app with a trivial root package' do
      before do
        write_file('package.yml', <<~CONTENTS)
          # This file represents the root package of the application
          # Please validate the configuration using `bin/packwerk validate` (for Rails applications) or running the auto generated
          # test case (for non-Rails projects). You can then use `packwerk check` to check your code.
          
          # Turn on dependency checks for this package
          enforce_dependencies: false
          
          # Turn on privacy checks for this package
          # enforcing privacy is often not useful for the root package, because it would require defining a public interface
          # for something that should only be a thin wrapper in the first place.
          # We recommend enabling this for any new packages you create to aid with encapsulation.
          enforce_privacy: false
          
          # By default the public path will be app/public/, however this may not suit all applications' architecture so
          # this allows you to modify what your package's public path is.
          # public_path: app/public/
          
          # A list of this package's dependencies
          # Note that packages in this list require their own `package.yml` file
          dependencies:
        CONTENTS
      end

      let(:expected_package) do
        ParsePackwerk::Package.new(
          name: '.',
          enforce_dependencies: false,
          enforce_privacy: false,
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('package_todo.yml'))
      end

      it 'correctly finds the package YML' do
        expect(expected_package.yml).to eq Pathname.new('package.yml')
      end

      it 'correctly finds the package directory' do
        expect(expected_package.directory).to eq Pathname.new('.')
      end

      it { is_expected.to have_matching_package expected_package, expected_package_todo }
    end

    context 'in app that enforces privacy and dependencies' do
      before do
        write_file('packs/package_1/package.yml', <<~CONTENTS)
          enforce_dependencies: true
          enforce_privacy: true
        CONTENTS

        write_file('package.yml', <<~CONTENTS)
          # This file represents the root package of the application
          # Please validate the configuration using `bin/packwerk validate` (for Rails applications) or running the auto generated
          # test case (for non-Rails projects). You can then use `packwerk check` to check your code.
          
          # Turn on dependency checks for this package
          enforce_dependencies: false
          
          # Turn on privacy checks for this package
          # enforcing privacy is often not useful for the root package, because it would require defining a public interface
          # for something that should only be a thin wrapper in the first place.
          # We recommend enabling this for any new packages you create to aid with encapsulation.
          enforce_privacy: false
          
          # By default the public path will be app/public/, however this may not suit all applications' architecture so
          # this allows you to modify what your package's public path is.
          # public_path: app/public/
          
          # A list of this package's dependencies
          # Note that packages in this list require their own `package.yml` file
          dependencies:
        CONTENTS
      end

      let(:expected_root_package) do
        ParsePackwerk::Package.new(
          name: '.',
          enforce_dependencies: false,
          enforce_privacy: false,
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_root_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('package_todo.yml'))
      end

      it { is_expected.to have_matching_package expected_root_package, expected_root_package_todo }

      let(:expected_domain_package) do
        ParsePackwerk::Package.new(
          name: 'packs/package_1',
          enforce_dependencies: true,
          enforce_privacy: true,
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_domain_package_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('packs/package_1/package_todo.yml'))
      end

      it 'correctly finds the package YML' do
        expect(expected_domain_package.yml).to eq Pathname.new('packs/package_1/package.yml')
      end

      it 'correctly finds the package directory' do
        expect(expected_domain_package.directory).to eq Pathname.new('packs/package_1')
      end

      it { is_expected.to have_matching_package expected_domain_package, expected_domain_package_package_todo }
    end

    context 'in app that has public_path' do
      before do
        write_file('packs/package_1/package.yml', <<~CONTENTS)
          enforce_dependencies: true
          enforce_privacy: true
          public_path: other/path
        CONTENTS

        write_file('package.yml', <<~CONTENTS)
          # This file represents the root package of the application
          # Please validate the configuration using `bin/packwerk validate` (for Rails applications) or running the auto generated
          # test case (for non-Rails projects). You can then use `packwerk check` to check your code.
          
          # Turn on dependency checks for this package
          enforce_dependencies: false
          
          # Turn on privacy checks for this package
          # enforcing privacy is often not useful for the root package, because it would require defining a public interface
          # for something that should only be a thin wrapper in the first place.
          # We recommend enabling this for any new packages you create to aid with encapsulation.
          enforce_privacy: false
          
          # By default the public path will be app/public/, however this may not suit all applications' architecture so
          # this allows you to modify what your package's public path is.
          # public_path: app/public/
          
          # A list of this package's dependencies
          # Note that packages in this list require their own `package.yml` file
          dependencies:
        CONTENTS
      end

      let(:expected_root_package) do
        ParsePackwerk::Package.new(
          name: '.',
          enforce_dependencies: false,
          enforce_privacy: false,
          public_path: 'app/public',
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_root_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('package_todo.yml'))
      end

      it { is_expected.to have_matching_package expected_root_package, expected_root_package_todo }

      let(:expected_domain_package) do
        ParsePackwerk::Package.new(
          name: 'packs/package_1',
          enforce_dependencies: true,
          enforce_privacy: true,
          public_path: 'other/path',
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('packs/package_1/package_todo.yml'))
      end

      it { is_expected.to have_matching_package expected_domain_package, expected_package_todo }
    end

    context 'in app that has metadata' do
      before do
        write_file('packs/package_1/package.yml', <<~CONTENTS)
          enforce_dependencies: true
          enforce_privacy: true
          metadata:
            string_key: this_is_a_string
            obviously_a_boolean_key: false
            not_obviously_a_boolean_key: no
            numeric_key: 123
        CONTENTS

        write_file('package.yml', <<~CONTENTS)
          # This file represents the root package of the application
          # Please validate the configuration using `bin/packwerk validate` (for Rails applications) or running the auto generated
          # test case (for non-Rails projects). You can then use `packwerk check` to check your code.
          
          # Turn on dependency checks for this package
          enforce_dependencies: false
          
          # Turn on privacy checks for this package
          # enforcing privacy is often not useful for the root package, because it would require defining a public interface
          # for something that should only be a thin wrapper in the first place.
          # We recommend enabling this for any new packages you create to aid with encapsulation.
          enforce_privacy: false
          
          # By default the public path will be app/public/, however this may not suit all applications' architecture so
          # this allows you to modify what your package's public path is.
          # public_path: app/public/
          
          # A list of this package's dependencies
          # Note that packages in this list require their own `package.yml` file
          dependencies:
        CONTENTS
      end

      let(:expected_root_package) do
        ParsePackwerk::Package.new(
          name: '.',
          enforce_dependencies: false,
          enforce_privacy: false,
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_root_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('package_todo.yml'))
      end

      it { is_expected.to have_matching_package expected_root_package, expected_root_package_todo }

      let(:expected_domain_package) do
        ParsePackwerk::Package.new(
          name: 'packs/package_1',
          enforce_dependencies: true,
          enforce_privacy: true,
          dependencies: [],
          metadata: {
            'string_key' => 'this_is_a_string',
            'obviously_a_boolean_key' => false,
            'not_obviously_a_boolean_key' => false,
            'numeric_key' => 123,
          },
          config: {},
        )
      end

      let(:expected_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('packs/package_1/package_todo.yml'))
      end

      it { is_expected.to have_matching_package expected_domain_package, expected_package_todo }
    end

    context 'in app that has violations' do
      before do
        write_file('packs/package_2/package_todo.yml', <<~CONTENTS)
          # This file contains a list of dependencies that are not part of the long term plan for ..
          # We should generally work to reduce this list, but not at the expense of actually getting work done.
          #
          # You can regenerate this file using the following command:
          #
          # bundle exec packwerk update-deprecations .
          ---
          packs/package_1:
            "SomeConstant":
              violations:
              - dependency
              files:
              - packs/package_1/lib/some_file.rb
          '.':
            "SomeRootConstant":
              violations:
              - dependency
              files:
              - root_file.rb
            "SomeOtherRootConstant":
              violations:
              - dependency
              files:
              - root_file.rb
        CONTENTS

        write_file('packs/package_2/package.yml', <<~CONTENTS)
          enforce_dependencies: true
          enforce_privacy: true
        CONTENTS

        write_file('packs/package_1/package_todo.yml', <<~CONTENTS)
          # This file contains a list of dependencies that are not part of the long term plan for ..
          # We should generally work to reduce this list, but not at the expense of actually getting work done.
          #
          # You can regenerate this file using the following command:
          #
          # bundle exec packwerk update-deprecations .
          ---
          packs/package_2:
            "SomePrivateConstant":
              violations:
              - privacy
              files:
              - packs/package_2/lib/some_other_file.rb
        CONTENTS

        write_file('packs/package_1/package.yml', <<~CONTENTS)
          enforce_dependencies: true
          enforce_privacy: true
          dependencies:
            - packs/package_2
        CONTENTS

        write_file('package_todo.yml', <<~CONTENTS)
          # This file contains a list of dependencies that are not part of the long term plan for ..
          # We should generally work to reduce this list, but not at the expense of actually getting work done.
          #
          # You can regenerate this file using the following command:
          #
          # bundle exec packwerk update-deprecations .
          ---
          packs/package_1:
            "SomeConstant":
              violations:
              - dependency
              files:
              - some_file.rb
          packs/package_2:
            "SomePrivateConstant":
              violations:
              - privacy
              files:
              - some_other_file.rb
              - path/to/file.rb
              - extended/path/to/file.rb
        CONTENTS

        write_file('package.yml', <<~CONTENTS)
          # This file represents the root package of the application
          # Please validate the configuration using `bin/packwerk validate` (for Rails applications) or running the auto generated
          # test case (for non-Rails projects). You can then use `packwerk check` to check your code.
          
          # Turn on dependency checks for this package
          enforce_dependencies: true
          
          # Turn on privacy checks for this package
          # enforcing privacy is often not useful for the root package, because it would require defining a public interface
          # for something that should only be a thin wrapper in the first place.
          # We recommend enabling this for any new packages you create to aid with encapsulation.
          enforce_privacy: false
          
          # By default the public path will be app/public/, however this may not suit all applications' architecture so
          # this allows you to modify what your package's public path is.
          # public_path: app/public/
          
          # A list of this package's dependencies
          # Note that packages in this list require their own `package.yml` file
          dependencies:
            - packs/package_2
        CONTENTS
      end

      let(:expected_root_package) do
        ParsePackwerk::Package.new(
          name: '.',
          enforce_dependencies: true,
          enforce_privacy: false,
          dependencies: ['packs/package_2'],
          metadata: {},
          config: {},
        )
      end

      let(:expected_package_todo) do
        ParsePackwerk::PackageTodo.new(
          pathname: Pathname.new('package_todo.yml'),
          violations: [
            ParsePackwerk::Violation.new(
              type: 'dependency',
              to_package_name: 'packs/package_1',
              class_name: 'SomeConstant',
              files: ['some_file.rb']
            ),
            ParsePackwerk::Violation.new(
              type: 'privacy',
              to_package_name: 'packs/package_2',
              class_name: 'SomePrivateConstant',
              files: ['some_other_file.rb', 'path/to/file.rb', 'extended/path/to/file.rb']
            ),
          ],
        )
      end

      it { is_expected.to have_matching_package expected_root_package, expected_package_todo }

      let(:expected_domain_package_1) do
        ParsePackwerk::Package.new(
          name: 'packs/package_1',
          enforce_dependencies: true,
          enforce_privacy: true,
          dependencies: ['packs/package_2'],
          metadata: {},
          config: {},
        )
      end

      let(:expected_package_todo_1) do
        ParsePackwerk::PackageTodo.new(
          pathname: Pathname.new('packs/package_1/package_todo.yml'),
          violations: [
            ParsePackwerk::Violation.new(
              type: 'privacy',
              to_package_name: 'packs/package_2',
              class_name: 'SomePrivateConstant',
              files: ['packs/package_2/lib/some_other_file.rb']
            ),
          ],
        )
      end

      it { is_expected.to have_matching_package expected_domain_package_1, expected_package_todo_1 }

      let(:expected_domain_package_2) do
        ParsePackwerk::Package.new(
          name: 'packs/package_2',
          enforce_dependencies: true,
          enforce_privacy: true,
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_domain_package_package_todo_2) do
        ParsePackwerk::PackageTodo.new(
          pathname: Pathname.new('packs/package_2/package_todo.yml'),
          violations: [
            ParsePackwerk::Violation.new(
              type: 'dependency',
              to_package_name: 'packs/package_1',
              class_name: 'SomeConstant',
              files: ['packs/package_1/lib/some_file.rb']
            ),
            ParsePackwerk::Violation.new(
              type: 'dependency',
              to_package_name: '.',
              class_name: 'SomeRootConstant',
              files: ['root_file.rb']
            ),
            ParsePackwerk::Violation.new(
              type: 'dependency',
              to_package_name: '.',
              class_name: 'SomeOtherRootConstant',
              files: ['root_file.rb']
            ),
          ],
        )
      end

      it { is_expected.to have_matching_package expected_domain_package_2, expected_domain_package_package_todo_2 }
    end

    context 'in an app that has specified package paths' do
      context 'app has specified packs in a specific folder' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            package_paths:
              - 'packs/*'
          CONTENTS

          write_file('package.yml', <<~CONTENTS)
            enforce_dependencies: false
            enforce_privacy: false
          CONTENTS

          write_file('packs/my_pack/package.yml', <<~CONTENTS)
            enforce_dependencies: false
            enforce_privacy: false
          CONTENTS

          write_file('app/services/my_non_package_location/package.yml', <<~CONTENTS)
            enforce_dependencies: false
            enforce_privacy: false
          CONTENTS
        end

        it 'includes the correct set of packages' do
          expect(all_packages.count).to eq 2
          expect(all_packages.find{|p| p.name == '.'}).to_not be_nil
          expect(all_packages.find{|p| p.name == 'packs/my_pack'}).to_not be_nil
        end
      end

      context 'app has excluded packs in a specific folder' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            package_paths:
              - 'packs/*'
            exclude:
              - 'packs/pack_to_ignore/*'
          CONTENTS

          write_file('package.yml', <<~CONTENTS)
            enforce_dependencies: false
            enforce_privacy: false
          CONTENTS

          write_file('packs/my_pack/package.yml', <<~CONTENTS)
            enforce_dependencies: false
            enforce_privacy: false
          CONTENTS

          write_file('packs/pack_to_ignore/package.yml', <<~CONTENTS)
            enforce_dependencies: false
            enforce_privacy: false
          CONTENTS

          write_file('app/services/my_non_package_location/package.yml', <<~CONTENTS)
            enforce_dependencies: false
            enforce_privacy: false
          CONTENTS
        end

        it 'includes the correct set of packages' do
          expect(all_packages.count).to eq 2
          expect(all_packages.find{|p| p.name == '.'}).to_not be_nil
          expect(all_packages.find{|p| p.name == 'packs/my_pack'}).to_not be_nil
        end
      end
    end

    context 'in an app with no root package' do
      before do
        write_file('package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS

        write_file('packs/my_pack/package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS
      end

      it 'includes the correct set of packages' do
        expect(all_packages.count).to eq 2
        expect(all_packages.find{|p| p.name == '.'}).to_not be_nil
        expect(all_packages.find{|p| p.name == 'packs/my_pack'}).to_not be_nil
      end
    end

    context 'in an app with nested packs' do
      before do
        write_file('package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS

        write_file('packs/my_pack/package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS

        write_file('packs/my_pack/subpack/package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS
      end

      it 'includes the correct set of packages' do
        expect(all_packages.count).to eq 3
        expect(all_packages.find{|p| p.name == '.'}).to_not be_nil
        expect(all_packages.find{|p| p.name == 'packs/my_pack'}).to_not be_nil
        expect(all_packages.find{|p| p.name == 'packs/my_pack/subpack'}).to_not be_nil
      end
    end

    context 'in an app that does not use privacy checker' do
      before do
        write_file('package.yml', <<~CONTENTS)
          enforce_dependencies: false
        CONTENTS
      end

      let(:expected_package) do
        ParsePackwerk::Package.new(
          name: '.',
          enforce_dependencies: false,
          enforce_privacy: false,
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      let(:expected_package_todo) do
        ParsePackwerk::PackageTodo.from(Pathname.new('package_todo.yml'))
      end

      it 'correctly finds the package YML' do
        expect(expected_package.yml).to eq Pathname.new('package.yml')
      end

      it 'correctly finds the package directory' do
        expect(expected_package.directory).to eq Pathname.new('.')
      end

      it { is_expected.to have_matching_package expected_package, expected_package_todo }
    end

    context 'in app with an invalid package.yml' do
      before do
        write_file('packs/my_pack/package.yml', <<~CONTENTS)
        CONTENTS
      end

      it 'outputs an error message with the pathname' do
        expect{subject}.to raise_error(ParsePackwerk::PackageParseError, /Failed to parse `packs\/my_pack\/package.yml`. Please fix any issues with this package.yml OR add its containing folder to packwerk.yml `exclude`/)
      end
    end
  end

  describe 'ParsePackwerk::Package#violations' do
    context 'in app with a trivial root package' do
      before do
        write_file('package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS
      end

      it 'has no violations' do
        expect(ParsePackwerk.find('.').violations).to be_empty
      end
    end

    context 'in app that has violations' do
      before do
        write_file('package.yml', <<~CONTENTS)
          enforce_dependencies: true
          enforce_privacy: true
        CONTENTS

        write_file('packs/my_pack/package.yml', <<~CONTENTS)
          enforce_dependencies: true
          enforce_privacy: true
        CONTENTS

        write_file('packs/my_pack/package_todo.yml', <<~CONTENTS)
          # This file contains a list of dependencies that are not part of the long term plan for ..
          # We should generally work to reduce this list, but not at the expense of actually getting work done.
          #
          # You can regenerate this file using the following command:
          #
          # bundle exec packwerk update-deprecations .
          ---
          '.':
            "SomeRootConstant":
              violations:
              - dependency
              files:
              - packs/my_pack/my_file.rb
        CONTENTS
      end

      it 'has violations' do
        expected_violation = ParsePackwerk::Violation.new(class_name: "SomeRootConstant", files: ["packs/my_pack/my_file.rb"], to_package_name: ".", type: "dependency")
        actual_violations = ParsePackwerk.find('packs/my_pack').violations
        expect(actual_violations.count).to eq 1
        expect(actual_violations.first.class_name).to eq expected_violation.class_name
        expect(actual_violations.first.files).to eq expected_violation.files
        expect(actual_violations.first.to_package_name).to eq expected_violation.to_package_name
        expect(actual_violations.first.type).to eq expected_violation.type
      end
    end
  end

  describe '.yml' do
    let(:configuration) { ParsePackwerk.yml }

    describe 'exclude' do
      subject { configuration.exclude }

      context 'when the configuration file is not present' do
        it { is_expected.to contain_exactly(Bundler.bundle_path.join("**").to_s, "{bin,node_modules,script,tmp,vendor}/**/*") }
      end

      context 'configuration is present' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            exclude:
              - 'a/b/**/c.rb'
          CONTENTS
        end

        it { is_expected.to contain_exactly(Bundler.bundle_path.join("**").to_s, 'a/b/**/c.rb') }
      end

      context 'when the exclude option is not defined' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            # empty file
          CONTENTS
        end

        it { is_expected.to contain_exactly(Bundler.bundle_path.join("**").to_s, "{bin,node_modules,script,tmp,vendor}/**/*") }
      end

      context 'when the exclude option is a string and not a list of strings' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            exclude: 'a/b/**/c.rb'
          CONTENTS
        end
        it { is_expected.to contain_exactly(Bundler.bundle_path.join("**").to_s, 'a/b/**/c.rb') }
      end
    end

    describe 'package_paths' do
      subject { configuration.package_paths }

      context 'when the configuration file is not present' do
        it { is_expected.to contain_exactly("**/", '.') }
      end

      context 'configuration is present' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            package_paths:
              - 'packs/*'
          CONTENTS
        end

        it { is_expected.to contain_exactly('packs/*', '.') }
      end

      context 'when the package paths option is not defined' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            # empty file
          CONTENTS
        end

        it { is_expected.to contain_exactly("**/", '.') }
      end

      context 'when the package paths option is a string and not a list of strings' do
        before do
          write_file('packwerk.yml', <<~CONTENTS)
            package_paths: 'packs/*'
          CONTENTS
        end
        it { is_expected.to contain_exactly('packs/*', '.') }
      end
    end
  end

  describe 'ParsePackwerk.package_from_path' do
    before do
      write_file('packs/package_1/package.yml', <<~CONTENTS)
        enforce_dependencies: true
        enforce_privacy: true
      CONTENTS

      write_file('packs/package_1_new/package.yml', <<~CONTENTS)
        enforce_dependencies: true
        enforce_privacy: false
      CONTENTS

      write_file('package.yml', <<~CONTENTS)
        enforce_dependencies: false
        enforce_privacy: false
      CONTENTS
    end

    let(:expected_package_1) do
      ParsePackwerk::Package.new(
        name: 'packs/package_1',
        enforce_dependencies: true,
        enforce_privacy: true,
        dependencies: [],
        metadata: {},
        config: {},
      )
    end

    let(:expected_package_1_new) do
      ParsePackwerk::Package.new(
        name: 'packs/package_1_new',
        enforce_dependencies: true,
        enforce_privacy: false,
        dependencies: [],
        metadata: {},
        config: {},
      )
    end

    context 'given a filepath in pack_1' do
      let(:filepath) { 'packs/package_1/path/to/file.rb' }

      it 'returns the correct package' do
        package = ParsePackwerk.package_from_path(filepath)

        expect(package).to have_attributes({
          name: expected_package_1.name,
          enforce_dependencies: expected_package_1.enforce_dependencies,
          enforce_privacy: expected_package_1.enforce_privacy,
        })
      end
    end

    context 'given a file path in pack_1_new' do
      let(:filepath) { 'packs/package_1_new/path/to/file.rb' }

      it 'returns the correct package' do
        package = ParsePackwerk.package_from_path(filepath)

        expect(package).to have_attributes({
          name: expected_package_1_new.name,
          enforce_dependencies: expected_package_1_new.enforce_dependencies,
          enforce_privacy: expected_package_1_new.enforce_privacy,
        })
      end
    end

    context 'given a file path that is exactly the root of a pack' do
      let(:filepath) { 'packs/package_1' }

      it 'returns the correct pack' do
        package = ParsePackwerk.package_from_path(filepath)

        expect(package).to have_attributes({
          name: expected_package_1.name,
          enforce_dependencies: expected_package_1.enforce_dependencies,
          enforce_privacy: expected_package_1.enforce_privacy,
        })
      end
    end

    context 'given a file path not in a pack' do
      let(:filepath) { 'path/to/file.rb' }

      let(:expected_root_package) do
        ParsePackwerk::Package.new(
          name: '.',
          enforce_dependencies: false,
          enforce_privacy: false,
          dependencies: [],
          metadata: {},
          config: {},
        )
      end

      it 'returns the root pack' do
        package = ParsePackwerk.package_from_path(filepath)

        expect(package).to have_attributes({
          name: expected_root_package.name,
          enforce_dependencies: expected_root_package.enforce_dependencies,
          enforce_privacy: expected_root_package.enforce_privacy,
        })
      end
    end

    context 'in an app with nested packs' do
      before do
        write_file('package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS

        write_file('packs/my_pack/package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS

        write_file('packs/my_pack/file.rb')

        write_file('packs/my_pack/subpack/package.yml', <<~CONTENTS)
          enforce_dependencies: false
          enforce_privacy: false
        CONTENTS

        write_file('packs/my_pack/subpack/file.rb')
      end

      it 'distinguishes between files in nested packs and parent packs' do
        expect(ParsePackwerk.package_from_path('packs/my_pack/subpack/file.rb').name).to eq 'packs/my_pack/subpack'
        expect(ParsePackwerk.package_from_path('packs/my_pack/file.rb').name).to eq 'packs/my_pack'
      end
    end
  end

  describe 'ParsePackwerk.write_package_yml' do
    let(:package_dir) { Pathname.new('packs/example_pack') }
    let(:package_yml) { package_dir.join('package.yml') }
    let(:package_todo_yml) { package_dir.join('package_todo.yml') }

    def build_pack(public_path: 'app/public', enforce_privacy: true, dependencies: [], metadata: {}, config: {})
      ParsePackwerk::Package.new(
        name: package_dir.to_s,
        enforce_dependencies: true,
        enforce_privacy: enforce_privacy,
        public_path: public_path,
        dependencies: dependencies,
        metadata: metadata,
        config: config,
      )
    end

    def pack_as_hash(package)
      {
        name: package.name,
        enforce_dependencies: package.enforce_dependencies,
        enforce_privacy: package.enforce_privacy,
        dependencies: package.dependencies,
        metadata: package.metadata,
      }
    end

    context 'a simple package' do
      let(:package) { build_pack }

      it 'writes the right package' do
        ParsePackwerk.write_package_yml!(package)
        expect(package_yml.read).to eq <<~PACKAGEYML
          enforce_dependencies: true
          enforce_privacy: true
        PACKAGEYML

        expect(all_packages.count).to eq 1
        expect(pack_as_hash(all_packages.first)).to eq pack_as_hash(package)
      end
    end

    context 'package with public_path' do
      let(:package) do
        build_pack(public_path: 'other/path')
      end

      it 'writes the right package' do
        ParsePackwerk.write_package_yml!(package)
        expect(package_yml.read).to eq <<~PACKAGEYML
          enforce_dependencies: true
          enforce_privacy: true
          public_path: other/path
        PACKAGEYML

        expect(all_packages.count).to eq 1
        expect(pack_as_hash(all_packages.first)).to eq pack_as_hash(package)
      end
    end

    context 'package with strict checker enforcement' do
      let(:package) do
        build_pack(enforce_privacy: 'strict')
      end

      it 'writes the right package' do
        ParsePackwerk.write_package_yml!(package)
        expect(package_yml.read).to eq <<~PACKAGEYML
          enforce_dependencies: true
          enforce_privacy: strict
        PACKAGEYML

        expect(all_packages.count).to eq 1
        expect(pack_as_hash(all_packages.first)).to eq pack_as_hash(package)
      end
    end

    context 'package with dependencies' do
      let(:package) do
        build_pack(dependencies: ['my_other_pack1', 'my_other_pack2'])
      end

      it 'writes the right package' do
        ParsePackwerk.write_package_yml!(package)
        expect(package_yml.read).to eq <<~PACKAGEYML
          enforce_dependencies: true
          enforce_privacy: true
          dependencies:
            - my_other_pack1
            - my_other_pack2
        PACKAGEYML

        expect(all_packages.count).to eq 1
        expect(pack_as_hash(all_packages.first)).to eq pack_as_hash(package)
      end
    end

    context 'package with metadata' do
      let(:package) do
        build_pack(metadata: {
          'owner' => 'Mission > Team',
          'protections' => { 'prevent_untyped_api' => 'fail_if_any', 'prevent_violations' => false },
        })
      end

      it 'writes the right package' do
        ParsePackwerk.write_package_yml!(package)

        expect(package_yml.read).to eq <<~PACKAGEYML
          enforce_dependencies: true
          enforce_privacy: true
          metadata:
            owner: Mission > Team
            protections:
              prevent_untyped_api: fail_if_any
              prevent_violations: false
        PACKAGEYML

        expect(all_packages.count).to eq 1
        expect(pack_as_hash(all_packages.first)).to eq pack_as_hash(package)
      end

      context 'overwriting an existing package file' do
        before do
          write_file(package_yml, <<~CONTENTS)
            enforce_dependencies: true
            enforce_privacy: true
            public_path: other/path
            dependencies:
            - packs/package_2
          CONTENTS
        end

        let(:existing_package) do
          ParsePackwerk.find('packs/example_pack')
        end

        it 'allows you to remove the dependencies list' do
          new_package = existing_package.with(dependencies: [])

          ParsePackwerk.write_package_yml!(new_package)

          expect(package_yml.read).to eq <<~PACKAGEYML
            enforce_dependencies: true
            enforce_privacy: true
            public_path: other/path
          PACKAGEYML
        end
      end
    end

    context 'package with other top-level config' do
      let(:package) do
        build_pack(config: {
          'my_special_key' => { 'blah' => 1 },
          'my_other_special_key' => true
        })
      end

      it 'writes the right package' do
        ParsePackwerk.write_package_yml!(package)

        expect(package_yml.read).to eq <<~PACKAGEYML
          enforce_dependencies: true
          enforce_privacy: true
          my_special_key:
            blah: 1
          my_other_special_key: true
        PACKAGEYML

        expect(all_packages.count).to eq 1
        expect(pack_as_hash(all_packages.first)).to eq pack_as_hash(package)
      end
    end

    context 'app does not use privacy checker' do
      let(:write_packwerk_yml) do
        write_file('packwerk.yml', '{}')
      end

      let(:package) { build_pack(enforce_privacy: false) }

      it 'writes the right package' do
        ParsePackwerk.write_package_yml!(package)
        expect(package_yml.read).to eq <<~PACKAGEYML
          enforce_dependencies: true
        PACKAGEYML

        expect(all_packages.count).to eq 1
        expect(pack_as_hash(all_packages.first)).to eq pack_as_hash(package)
      end
    end
  end
end
