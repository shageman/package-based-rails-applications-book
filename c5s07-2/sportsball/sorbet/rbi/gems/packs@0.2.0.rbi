# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `packs` gem.
# Please instead update this file by running `bin/tapioca gem packs`.


# source://packs//lib/packs/private/file_move_operation.rb#3
module Packs
  class << self
    # source://packs//lib/packs.rb#146
    sig { params(pack_name: ::String, dependency_name: ::String).void }
    def add_dependency!(pack_name:, dependency_name:); end

    # source://packs-specification/0.0.10/lib/packs-specification.rb#19
    sig { returns(T::Array[::Packs::Pack]) }
    def all; end

    # source://packs//lib/packs.rb#261
    sig { void }
    def bust_cache!; end

    # source://packs//lib/packs.rb#52
    sig { params(files: T::Array[::String]).returns(T::Boolean) }
    def check(files); end

    # source://packs//lib/packs/configuration.rb#69
    sig { returns(::Packs::Configuration) }
    def config; end

    # @yield [config]
    #
    # source://packs//lib/packs/configuration.rb#76
    sig { params(blk: T.proc.params(arg0: ::Packs::Configuration).void).void }
    def configure(&blk); end

    # source://packs//lib/packs.rb#69
    sig do
      params(
        pack_name: ::String,
        enforce_privacy: T::Boolean,
        enforce_layers: T::Boolean,
        enforce_dependencies: T.nilable(T::Boolean),
        team: T.nilable(::CodeTeams::Team)
      ).void
    end
    def create_pack!(pack_name:, enforce_privacy: T.unsafe(nil), enforce_layers: T.unsafe(nil), enforce_dependencies: T.unsafe(nil), team: T.unsafe(nil)); end

    # source://packs-specification/0.0.10/lib/packs-specification.rb#24
    sig { params(name: ::String).returns(T.nilable(::Packs::Pack)) }
    def find(name); end

    # source://packs-specification/0.0.10/lib/packs-specification.rb#29
    sig { params(file_path: T.any(::Pathname, ::String)).returns(T.nilable(::Packs::Pack)) }
    def for_file(file_path); end

    # source://packs//lib/packs.rb#267
    sig { void }
    def lint_package_todo_yml_files!; end

    # source://packs//lib/packs.rb#272
    sig { params(packs: T::Array[::Packs::Pack]).void }
    def lint_package_yml_files!(packs); end

    # source://packs//lib/packs.rb#233
    sig { params(type: ::String, pack_name: T.nilable(::String), limit: ::Integer).void }
    def list_top_violations(type:, pack_name:, limit:); end

    # source://packs//lib/packs.rb#120
    sig do
      params(
        paths_relative_to_root: T::Array[::String],
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def make_public!(paths_relative_to_root: T.unsafe(nil), per_file_processors: T.unsafe(nil)); end

    # source://packs//lib/packs.rb#203
    sig do
      params(
        pack_name: ::String,
        destination: ::String,
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def move_to_folder!(pack_name:, destination:, per_file_processors: T.unsafe(nil)); end

    # source://packs//lib/packs.rb#92
    sig do
      params(
        pack_name: ::String,
        paths_relative_to_root: T::Array[::String],
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def move_to_pack!(pack_name:, paths_relative_to_root: T.unsafe(nil), per_file_processors: T.unsafe(nil)); end

    # source://packs//lib/packs.rb#173
    sig do
      params(
        pack_name: ::String,
        parent_name: ::String,
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def move_to_parent!(pack_name:, parent_name:, per_file_processors: T.unsafe(nil)); end

    # source://packs//lib/packs.rb#252
    sig { params(file: ::String, find: ::Pathname, replace_with: ::Pathname).void }
    def replace_in_file(file:, find:, replace_with:); end

    # source://packs//lib/packs.rb#29
    sig { void }
    def start_interactive_mode!; end

    # source://packs//lib/packs.rb#34
    sig { returns(T::Boolean) }
    def update; end

    # source://packs//lib/packs.rb#43
    sig { returns(T::Boolean) }
    def validate; end
  end
end

# source://packs//lib/packs/cli.rb#6
class Packs::CLI < ::Thor
  # source://packs//lib/packs/cli.rb#34
  sig { params(from_pack: ::String, to_pack: ::String).void }
  def add_dependency(from_pack, to_pack); end

  # source://packs//lib/packs/cli.rb#121
  sig { params(paths: ::String).void }
  def check(*paths); end

  # source://packs//lib/packs/cli.rb#14
  sig { params(pack_name: ::String).void }
  def create(pack_name); end

  # @raise [StandardError]
  #
  # source://packs//lib/packs/cli.rb#136
  sig { params(pack_names: ::String).void }
  def get_info(*pack_names); end

  # source://packs//lib/packs/cli.rb#103
  sig { void }
  def lint_package_todo_yml_files; end

  # source://packs//lib/packs/cli.rb#109
  sig { params(pack_names: ::String).void }
  def lint_package_yml_files(*pack_names); end

  # @raise [StandardError]
  #
  # source://packs//lib/packs/cli.rb#62
  sig { params(type: ::String, pack_name: T.nilable(::String)).void }
  def list_top_violations(type, pack_name = T.unsafe(nil)); end

  # source://packs//lib/packs/cli.rb#80
  sig { params(paths: ::String).void }
  def make_public(*paths); end

  # source://packs//lib/packs/cli.rb#93
  sig { params(pack_name: ::String, paths: ::String).void }
  def move(pack_name, *paths); end

  # source://packs//lib/packs/cli.rb#169
  sig { params(pack_name: ::String, destination: ::String).void }
  def move_to_folder(pack_name, destination); end

  # source://packs//lib/packs/cli.rb#159
  sig { params(child_pack_name: ::String, parent_pack_name: ::String).void }
  def move_to_parent(child_pack_name, parent_pack_name); end

  # source://packs//lib/packs/cli.rb#152
  sig { void }
  def rename; end

  # source://packs//lib/packs/cli.rb#127
  sig { void }
  def update; end

  # source://packs//lib/packs/cli.rb#115
  sig { void }
  def validate; end

  private

  # source://packs//lib/packs/cli.rb#187
  sig { void }
  def exit_successfully; end

  # source://packs//lib/packs/cli.rb#182
  sig { params(pack_names: T::Array[::String]).returns(T::Array[::Packs::Pack]) }
  def parse_pack_names(pack_names); end
end

# source://packs//lib/packs/cli.rb#42
Packs::CLI::POSIBLE_TYPES = T.let(T.unsafe(nil), Array)

# source://packs//lib/packs/code_ownership_post_processor.rb#4
class Packs::CodeOwnershipPostProcessor
  include ::Packs::PerFileProcessorInterface

  # source://packs//lib/packs/code_ownership_post_processor.rb#9
  sig { void }
  def initialize; end

  # source://packs//lib/packs/code_ownership_post_processor.rb#44
  sig { override.params(file_move_operations: T::Array[::Packs::Private::FileMoveOperation]).void }
  def after_move_files!(file_move_operations); end

  # source://packs//lib/packs/code_ownership_post_processor.rb#15
  sig { override.params(file_move_operation: ::Packs::Private::FileMoveOperation).void }
  def before_move_file!(file_move_operation); end
end

# source://packs//lib/packs/configuration.rb#7
class Packs::Configuration
  # source://packs//lib/packs/configuration.rb#30
  sig { void }
  def initialize; end

  # source://packs//lib/packs/configuration.rb#43
  sig { void }
  def bust_cache!; end

  # source://packs//lib/packs/configuration.rb#48
  sig { returns(T::Boolean) }
  def default_enforce_dependencies; end

  # source://packs//lib/packs/configuration.rb#38
  sig { returns(T::Boolean) }
  def enforce_dependencies; end

  # source://packs//lib/packs/configuration.rb#14
  sig { params(enforce_dependencies: T::Boolean).void }
  def enforce_dependencies=(enforce_dependencies); end

  # source://packs//lib/packs/configuration.rb#27
  sig { returns(T.proc.params(output: ::String).void) }
  def on_package_todo_lint_failure; end

  # @return [OnPackageTodoLintFailure]
  #
  # source://packs//lib/packs/configuration.rb#27
  def on_package_todo_lint_failure=(_arg0); end

  # source://packs//lib/packs/configuration.rb#53
  sig { returns(::Pathname) }
  def readme_template_pathname; end

  # source://packs//lib/packs/configuration.rb#20
  sig { returns(T::Boolean) }
  def use_pks; end

  # @return [Boolean]
  #
  # source://packs//lib/packs/configuration.rb#20
  def use_pks=(_arg0); end

  # source://packs//lib/packs/configuration.rb#17
  sig { returns(::Packs::UserEventLogger) }
  def user_event_logger; end

  # @return [UserEventLogger]
  #
  # source://packs//lib/packs/configuration.rb#17
  def user_event_logger=(_arg0); end
end

# source://packs//lib/packs/configuration.rb#10
Packs::Configuration::CONFIGURATION_PATHNAME = T.let(T.unsafe(nil), Pathname)

# source://packs//lib/packs/configuration.rb#11
Packs::Configuration::DEFAULT_README_TEMPLATE_PATHNAME = T.let(T.unsafe(nil), Pathname)

# source://packs//lib/packs/configuration.rb#22
Packs::Configuration::OnPackageTodoLintFailure = T.type_alias { T.proc.params(output: ::String).void }

# source://packs//lib/packs/default_user_event_logger.rb#4
class Packs::DefaultUserEventLogger
  include ::Packs::UserEventLogger
end

# source://packs//lib/packs/logging.rb#6
module Packs::Logging
  class << self
    # source://packs//lib/packs/logging.rb#33
    sig { params(str: ::String).void }
    def out(str); end

    # source://packs//lib/packs/logging.rb#23
    sig { params(text: ::String).void }
    def print(text); end

    # source://packs//lib/packs/logging.rb#18
    sig { params(text: ::String).void }
    def print_bold_green(text); end

    # source://packs//lib/packs/logging.rb#28
    sig { void }
    def print_divider; end

    # source://packs//lib/packs/logging.rb#10
    sig { params(title: ::String, block: T.proc.void).void }
    def section(title, &block); end
  end
end

# @abstract Subclasses must implement the `abstract` methods below.
#
# source://packs//lib/packs/per_file_processor_interface.rb#4
module Packs::PerFileProcessorInterface
  abstract!

  # source://packs//lib/packs/per_file_processor_interface.rb#14
  sig { overridable.params(file_move_operations: T::Array[::Packs::Private::FileMoveOperation]).void }
  def after_move_files!(file_move_operations); end

  # @abstract
  #
  # source://packs//lib/packs/per_file_processor_interface.rb#11
  sig { abstract.params(file_move_operation: ::Packs::Private::FileMoveOperation).void }
  def before_move_file!(file_move_operation); end
end

# source://packs//lib/packs/private/file_move_operation.rb#4
module Packs::Private
  class << self
    # source://packs//lib/packs/private.rb#382
    sig { params(pack_name: ::String, dependency_name: ::String).void }
    def add_dependency!(pack_name:, dependency_name:); end

    # source://packs//lib/packs/private.rb#444
    sig { params(package: ::ParsePackwerk::Package).void }
    def add_public_directory(package); end

    # source://packs//lib/packs/private.rb#455
    sig { params(package: ::ParsePackwerk::Package).void }
    def add_readme(package); end

    # source://packs//lib/packs/private.rb#530
    sig { void }
    def bust_cache!; end

    # source://packs//lib/packs/private.rb#20
    sig { params(pack_name: ::String).returns(::String) }
    def clean_pack_name(pack_name); end

    # source://packs//lib/packs/private.rb#56
    sig do
      params(
        pack_name: ::String,
        enforce_dependencies: T.nilable(T::Boolean),
        enforce_privacy: T::Boolean,
        enforce_layers: T::Boolean,
        team: T.nilable(::CodeTeams::Team)
      ).void
    end
    def create_pack!(pack_name:, enforce_dependencies:, enforce_privacy:, enforce_layers:, team:); end

    # source://packs//lib/packs/private.rb#477
    sig do
      params(
        pack_name: ::String,
        enforce_dependencies: T.nilable(T::Boolean),
        enforce_privacy: T::Boolean,
        enforce_layers: T::Boolean,
        team: T.nilable(::CodeTeams::Team)
      ).returns(::ParsePackwerk::Package)
    end
    def create_pack_if_not_exists!(pack_name:, enforce_dependencies:, enforce_privacy:, enforce_layers:, team: T.unsafe(nil)); end

    # source://packs//lib/packs/private.rb#555
    sig do
      params(
        before: T::Hash[::String, T.nilable(::String)],
        after: T::Hash[::String, T.nilable(::String)]
      ).returns(::String)
    end
    def diff_package_todo_yml(before, after); end

    # This function exists to give us something to stub in test
    #
    # source://packs//lib/packs/private.rb#780
    sig { params(code: T::Boolean).void }
    def exit_with(code); end

    # source://packs//lib/packs/private.rb#607
    sig do
      params(
        packs: T::Array[::Packs::Pack],
        format: ::Symbol,
        types: T::Array[::Symbol],
        include_date: T::Boolean
      ).void
    end
    def get_info(packs: T.unsafe(nil), format: T.unsafe(nil), types: T.unsafe(nil), include_date: T.unsafe(nil)); end

    # source://packs//lib/packs/private.rb#538
    sig { returns(T::Hash[::String, ::String]) }
    def get_package_todo_contents; end

    # source://packs//lib/packs/private.rb#425
    sig { params(origin: ::Pathname, destination: ::Pathname).void }
    def idempotent_mv(origin, destination); end

    # source://packs//lib/packs/private.rb#697
    sig { void }
    def lint_package_todo_yml_files!; end

    # source://packs//lib/packs/private.rb#732
    sig { params(packs: T::Array[::Packs::Pack]).void }
    def lint_package_yml_files!(packs); end

    # source://packs//lib/packs/private.rb#520
    sig { void }
    def load_client_configuration; end

    # source://packs//lib/packs/private.rb#335
    sig do
      params(
        paths_relative_to_root: T::Array[::String],
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def make_public!(paths_relative_to_root:, per_file_processors:); end

    # source://packs//lib/packs/private.rb#157
    sig do
      params(
        pack_name: ::String,
        destination: ::String,
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def move_to_folder!(pack_name:, destination:, per_file_processors: T.unsafe(nil)); end

    # source://packs//lib/packs/private.rb#88
    sig do
      params(
        pack_name: ::String,
        paths_relative_to_root: T::Array[::String],
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def move_to_pack!(pack_name:, paths_relative_to_root:, per_file_processors: T.unsafe(nil)); end

    # source://packs//lib/packs/private.rb#236
    sig do
      params(
        pack_name: ::String,
        parent_name: ::String,
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def move_to_parent!(pack_name:, parent_name:, per_file_processors: T.unsafe(nil)); end

    # source://packs//lib/packs/private.rb#412
    sig do
      params(
        file_move_operation: ::Packs::Private::FileMoveOperation,
        per_file_processors: T::Array[::Packs::PerFileProcessorInterface]
      ).void
    end
    def package_filepath(file_move_operation, per_file_processors); end

    # source://packs//lib/packs/private.rb#595
    sig { params(package: ::ParsePackwerk::Package).returns(T.nilable(::Packs::Pack)) }
    def packwerk_package_to_pack(package); end

    # source://packs//lib/packs/private.rb#584
    sig { params(packages: T::Array[::ParsePackwerk::Package]).returns(T::Array[::Packs::Pack]) }
    def packwerk_packages_to_packs(packages); end

    # source://packs//lib/packs/private.rb#765
    sig { returns(::String) }
    def rename_pack; end

    # source://packs//lib/packs/private.rb#35
    sig { params(file: ::String, find: ::Pathname, replace_with: ::Pathname).void }
    def replace_in_file(file:, find:, replace_with:); end

    # source://packs//lib/packs/private.rb#759
    sig { params(config: T::Hash[T.anything, T.anything]).returns(T::Hash[T.anything, T.anything]) }
    def sort_keys(config); end

    # This function exists to give us something to stub in test
    #
    # source://packs//lib/packs/private.rb#786
    sig { params(command: ::String).returns(T::Boolean) }
    def system_with(command); end

    # source://packs//lib/packs/private.rb#572
    sig { params(package_todo_files: T::Hash[::String, T.nilable(::String)], tmp_folder: ::String).void }
    def write_package_todo_to_tmp_folder(package_todo_files, tmp_folder); end
  end
end

# source://packs//lib/packs/private/file_move_operation.rb#5
class Packs::Private::FileMoveOperation < ::T::Struct
  const :origin_pathname, ::Pathname
  const :destination_pathname, ::Pathname
  const :destination_pack, ::ParsePackwerk::Package

  # source://packs//lib/packs/private/file_move_operation.rb#13
  sig { returns(T.nilable(::Packs::Pack)) }
  def origin_pack; end

  # source://packs//lib/packs/private/file_move_operation.rb#55
  sig { returns(::Packs::Private::FileMoveOperation) }
  def spec_file_move_operation; end

  private

  # source://packs//lib/packs/private/file_move_operation.rb#89
  sig { returns(::String) }
  def filepath_without_pack_name; end

  # source://packs//lib/packs/private/file_move_operation.rb#110
  sig { params(path: ::Pathname).returns(::Packs::Private::FileMoveOperation) }
  def relative_to(path); end

  # source://packs//lib/packs/private/file_move_operation.rb#94
  sig { params(pathname: ::Pathname, file_extension: ::String).returns(::Pathname) }
  def spec_pathname_for_app(pathname, file_extension); end

  # source://packs//lib/packs/private/file_move_operation.rb#102
  sig { params(pathname: ::Pathname, file_extension: ::String, folder: ::String).returns(::Pathname) }
  def spec_pathname_for_non_app(pathname, file_extension, folder); end

  class << self
    # source://packs//lib/packs/private/file_move_operation.rb#33
    sig { params(origin_pathname: ::Pathname).returns(::Pathname) }
    def destination_pathname_for_new_public_api(origin_pathname); end

    # source://packs//lib/packs/private/file_move_operation.rb#23
    sig { params(origin_pathname: ::Pathname, new_package_root: ::Pathname).returns(::Pathname) }
    def destination_pathname_for_package_move(origin_pathname, new_package_root); end

    # source://packs//lib/packs/private/file_move_operation.rb#78
    sig { params(filepath: ::Pathname, pack: T.nilable(::Packs::Pack)).returns(::String) }
    def get_filepath_without_pack_name(filepath, pack); end

    # source://packs//lib/packs/private/file_move_operation.rb#18
    sig { params(origin_pathname: ::Pathname).returns(T.nilable(::Packs::Pack)) }
    def get_origin_pack(origin_pathname); end

    # source://sorbet-runtime/0.5.11835/lib/types/struct.rb#13
    def inherited(s); end
  end
end

# source://packs//lib/packs/private/interactive_cli/team_selector.rb#5
module Packs::Private::InteractiveCli
  class << self
    # source://packs//lib/packs/private/interactive_cli.rb#30
    sig { params(prompt: T.nilable(::TTY::Prompt)).void }
    def start!(prompt: T.unsafe(nil)); end
  end
end

# source://packs//lib/packs/private/interactive_cli/file_selector.rb#6
class Packs::Private::InteractiveCli::FileSelector
  class << self
    # source://packs//lib/packs/private/interactive_cli/file_selector.rb#10
    sig { params(prompt: ::TTY::Prompt).returns(T::Array[::String]) }
    def select(prompt); end
  end
end

# source://packs//lib/packs/private/interactive_cli/pack_directory_selector.rb#6
class Packs::Private::InteractiveCli::PackDirectorySelector
  class << self
    # source://packs//lib/packs/private/interactive_cli/pack_directory_selector.rb#10
    sig { params(prompt: ::TTY::Prompt, question_text: ::String).returns(::String) }
    def select(prompt, question_text: T.unsafe(nil)); end
  end
end

# source://packs//lib/packs/private/interactive_cli/pack_selector.rb#6
class Packs::Private::InteractiveCli::PackSelector
  class << self
    # source://packs//lib/packs/private/interactive_cli/pack_selector.rb#33
    sig { params(prompt: ::TTY::Prompt, question_text: ::String).returns(T::Array[::Packs::Pack]) }
    def single_or_all_pack_multi_select(prompt, question_text: T.unsafe(nil)); end

    # source://packs//lib/packs/private/interactive_cli/pack_selector.rb#10
    sig { params(prompt: ::TTY::Prompt, question_text: ::String).returns(::Packs::Pack) }
    def single_pack_select(prompt, question_text: T.unsafe(nil)); end
  end
end

# source://packs//lib/packs/private/interactive_cli/team_selector.rb#6
class Packs::Private::InteractiveCli::TeamSelector
  class << self
    # source://packs//lib/packs/private/interactive_cli/team_selector.rb#34
    sig { params(prompt: ::TTY::Prompt, question_text: ::String).returns(T::Array[::CodeTeams::Team]) }
    def multi_select(prompt, question_text: T.unsafe(nil)); end

    # source://packs//lib/packs/private/interactive_cli/team_selector.rb#10
    sig { params(prompt: ::TTY::Prompt, question_text: ::String).returns(T.nilable(::CodeTeams::Team)) }
    def single_select(prompt, question_text: T.unsafe(nil)); end
  end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/interface.rb#6
module Packs::Private::InteractiveCli::UseCases; end

# source://packs//lib/packs/private/interactive_cli/use_cases/add_dependency.rb#7
class Packs::Private::InteractiveCli::UseCases::AddDependency
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/add_dependency.rb#13
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/add_dependency.rb#23
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/check.rb#7
class Packs::Private::InteractiveCli::UseCases::Check
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/check.rb#18
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/check.rb#13
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/create.rb#7
class Packs::Private::InteractiveCli::UseCases::Create
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/create.rb#13
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/create.rb#20
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/get_info.rb#7
class Packs::Private::InteractiveCli::UseCases::GetInfo
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/get_info.rb#18
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/get_info.rb#13
  sig { override.returns(::String) }
  def user_facing_name; end
end

# @abstract Subclasses must implement the `abstract` methods below.
#
# source://packs//lib/packs/private/interactive_cli/use_cases/interface.rb#7
module Packs::Private::InteractiveCli::UseCases::Interface
  interface!

  # @abstract
  #
  # source://packs//lib/packs/private/interactive_cli/use_cases/interface.rb#26
  sig { abstract.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # @abstract
  #
  # source://packs//lib/packs/private/interactive_cli/use_cases/interface.rb#29
  sig { abstract.returns(::String) }
  def user_facing_name; end

  class << self
    # source://packs//lib/packs/private/interactive_cli/use_cases/interface.rb#21
    sig { returns(T::Array[::Packs::Private::InteractiveCli::UseCases::Interface]) }
    def all; end

    # source://packs//lib/packs/private/interactive_cli/use_cases/interface.rb#14
    sig { params(base: T::Class[T.anything]).void }
    def included(base); end
  end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/lint_package_yml_files.rb#7
class Packs::Private::InteractiveCli::UseCases::LintPackageYmlFiles
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/lint_package_yml_files.rb#13
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/lint_package_yml_files.rb#19
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/make_public.rb#7
class Packs::Private::InteractiveCli::UseCases::MakePublic
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/make_public.rb#18
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/make_public.rb#13
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/move.rb#7
class Packs::Private::InteractiveCli::UseCases::Move
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/move.rb#13
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/move.rb#25
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/move_pack.rb#7
class Packs::Private::InteractiveCli::UseCases::MovePack
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/move_pack.rb#13
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/move_pack.rb#63
  sig { override.returns(::String) }
  def user_facing_name; end
end

# We have not yet pulled QueryPackwerk into open source, so we cannot include it in this CLI yet
#
# source://packs//lib/packs/private/interactive_cli/use_cases/query.rb#10
class Packs::Private::InteractiveCli::UseCases::Query
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/query.rb#21
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/query.rb#16
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/rename.rb#7
class Packs::Private::InteractiveCli::UseCases::Rename
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/rename.rb#18
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/rename.rb#13
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/update.rb#7
class Packs::Private::InteractiveCli::UseCases::Update
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/update.rb#18
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/update.rb#13
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/interactive_cli/use_cases/validate.rb#7
class Packs::Private::InteractiveCli::UseCases::Validate
  include ::Packs::Private::InteractiveCli::UseCases::Interface

  # source://packs//lib/packs/private/interactive_cli/use_cases/validate.rb#18
  sig { override.params(prompt: ::TTY::Prompt).void }
  def perform!(prompt); end

  # source://packs//lib/packs/private/interactive_cli/use_cases/validate.rb#13
  sig { override.returns(::String) }
  def user_facing_name; end
end

# source://packs//lib/packs/private/pack_relationship_analyzer.rb#5
module Packs::Private::PackRelationshipAnalyzer
  class << self
    # source://packs//lib/packs/private/pack_relationship_analyzer.rb#15
    sig { params(type: ::String, pack_name: T.nilable(::String), limit: ::Integer).void }
    def list_top_violations(type, pack_name, limit); end
  end
end

# source://packs//lib/packs/private.rb#550
Packs::Private::PackageTodoFiles = T.type_alias { T::Hash[::String, T.nilable(::String)] }

# source://packs//lib/packs/rubocop_post_processor.rb#4
class Packs::RubocopPostProcessor
  include ::Packs::PerFileProcessorInterface

  # source://packs//lib/packs/rubocop_post_processor.rb#9
  sig { override.params(file_move_operation: ::Packs::Private::FileMoveOperation).void }
  def before_move_file!(file_move_operation); end

  # source://packs//lib/packs/rubocop_post_processor.rb#26
  sig { returns(T::Boolean) }
  def rubocop_enabled?; end
end

# source://packs//lib/packs/update_references_post_processor.rb#4
class Packs::UpdateReferencesPostProcessor
  include ::Packs::PerFileProcessorInterface

  # source://packs//lib/packs/update_references_post_processor.rb#15
  sig { override.params(file_move_operations: T::Array[::Packs::Private::FileMoveOperation]).void }
  def after_move_files!(file_move_operations); end

  # source://packs//lib/packs/update_references_post_processor.rb#10
  sig { override.params(file_move_operation: ::Packs::Private::FileMoveOperation).void }
  def before_move_file!(file_move_operation); end

  private

  # source://packs//lib/packs/update_references_post_processor.rb#44
  sig { params(file_name: ::String, origin_pack: ::String, destination_pack: ::String).void }
  def substitute_references!(file_name, origin_pack, destination_pack); end

  class << self
    # source://packs//lib/packs/update_references_post_processor.rb#37
    sig { returns(T::Boolean) }
    def ripgrep_enabled?; end
  end
end

# @abstract Subclasses must implement the `abstract` methods below.
#
# source://packs//lib/packs/user_event_logger.rb#4
module Packs::UserEventLogger
  abstract!

  # source://packs//lib/packs/user_event_logger.rb#82
  sig { params(pack_name: ::String).returns(::String) }
  def after_add_dependency(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#18
  sig { params(pack_name: ::String).returns(::String) }
  def after_create_pack(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#62
  sig { returns(::String) }
  def after_make_public; end

  # source://packs//lib/packs/user_event_logger.rb#116
  sig { params(pack_name: ::String).returns(::String) }
  def after_move_to_folder(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#40
  sig { params(pack_name: ::String).returns(::String) }
  def after_move_to_pack(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#98
  sig { params(pack_name: ::String).returns(::String) }
  def after_move_to_parent(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#75
  sig { params(pack_name: ::String).returns(::String) }
  def before_add_dependency(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#11
  sig { params(pack_name: ::String).returns(::String) }
  def before_create_pack(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#153
  sig { params(type: ::String, pack_name: T.nilable(::String), limit: ::Integer).returns(::String) }
  def before_list_top_violations(type, pack_name, limit); end

  # source://packs//lib/packs/user_event_logger.rb#55
  sig { returns(::String) }
  def before_make_public; end

  # source://packs//lib/packs/user_event_logger.rb#109
  sig { params(pack_name: ::String).returns(::String) }
  def before_move_to_folder(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#33
  sig { params(pack_name: ::String).returns(::String) }
  def before_move_to_pack(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#91
  sig { params(pack_name: ::String).returns(::String) }
  def before_move_to_parent(pack_name); end

  # source://packs//lib/packs/user_event_logger.rb#174
  sig { returns(::String) }
  def documentation_link; end

  # source://packs//lib/packs/user_event_logger.rb#127
  sig { params(pack_name: ::String).returns(::String) }
  def on_create_readme(pack_name); end
end
