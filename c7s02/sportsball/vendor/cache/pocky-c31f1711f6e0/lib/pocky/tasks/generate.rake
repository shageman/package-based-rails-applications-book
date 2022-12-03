require 'pocky'

namespace :pocky do
  desc 'Generate dependency graph for packwerk packages'
  task :generate, [:default_package, :filename, :dpi] do |_task, args|
    Pocky::Packwerk.generate(args)
  end
end
