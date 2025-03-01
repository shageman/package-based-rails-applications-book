# typed: ignore

require "dry/monads"
require "dry/operation"
require "hanami/action"
require "hanami/view"

module SportsballHanami
  class App < Hanami::App
    prepare_container do |container|
      container.autoloader.ignore("app")
    end
  end

  class Action < Hanami::Action
    include Dry::Monads[:result]
  end
end

Hanami.boot

module SportsballHanami
  class View < Hanami::View
  end

  class Operation < Dry::Operation
  end
end

Hanami::View::HTML::StringExtensions.class_eval do
  def html_safe
    ActiveSupport::SafeBuffer.new(self)
  end
end

HanamiPredictor::Slice.boot

# p Hanami.app.slices[:hanami_predictor].keys


