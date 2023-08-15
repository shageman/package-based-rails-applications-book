require_relative "lib/testengine/version"

Gem::Specification.new do |spec|
  spec.name        = "testengine"
  spec.version     = Testengine::VERSION
  spec.authors     = [""]
  spec.email       = [""]
  spec.homepage    = ""
  spec.summary     = "Summary of Testengine."
  spec.description = "Description of Testengine."

  spec.metadata['allowed_push_host'] = 'http://nowhere.atall'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'http://nowhere.atall'


  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.7"
end
