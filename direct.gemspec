
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

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", ">= 1.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "minitest", "~> 5.11"
end
