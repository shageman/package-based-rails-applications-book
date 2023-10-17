require "rubocop"

RSpec.describe "rubocop-packs validations" do
  it "has only valid config files" do
    config_files = Dir.glob("**/.rubocop.yml")
    config_files.each do |config_file|
      expect do
        config = RuboCop::ConfigLoader.load_file(File.expand_path(".") + "/.rubocop.yml", check: false)
        RuboCop::ConfigValidator.new(config).validate
      end.to_not raise_exception
    end
  end
end
