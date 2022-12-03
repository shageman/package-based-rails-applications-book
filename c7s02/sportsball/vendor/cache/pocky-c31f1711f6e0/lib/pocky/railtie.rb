require 'pocky'
require 'rails'

module Pocky
  class Railtie < Rails::Railtie
    railtie_name :pocky

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end