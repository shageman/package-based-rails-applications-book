# frozen_string_literal: true

require_relative 'pocky/version'
require_relative 'pocky/packwerk'

module Pocky
  require 'pocky/railtie' if defined?(Rails)
end
