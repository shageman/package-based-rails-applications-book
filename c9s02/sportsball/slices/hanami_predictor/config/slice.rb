# frozen_string_literal: true

module HanamiPredictor
  class Slice < Hanami::Slice
    autoloader.ignore(File.expand_path(File.join(__dir__, "..", "spec")))
  end
end
