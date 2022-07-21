
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "direct/version"

Gem::Specification.new do |spec|
  spec.name          = "direct"
  spec.version       = Direct::VERSION
  spec.authors       = ["Jim Gay"]
  spec.email         = ["jim@saturnflyer.com"]

  spec.summary       = %q{Direct objects to perform arbitrary blocks by name}
  spec.description   = %q{Direct objects to perform arbitrary blocks by name}
  spec.homepage      = "https://github.com/saturnflyer/direct"
  spec.license       = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md"]
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", ">= 1.0"
  spec.required_ruby_version = '>= 2.6'
end
