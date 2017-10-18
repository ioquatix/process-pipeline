# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "process/pipeline/version"

Gem::Specification.new do |spec|
	spec.name          = "process-pipeline"
	spec.version       = Process::Pipeline::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]

	spec.summary       = %q{Execute composable shell-like pipelines.}
	spec.homepage      = "https://github.com/ioquatix/process-pipeline"

	spec.files         = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(test|spec|features)/})
	end
	spec.require_paths = ["lib"]

	spec.add_dependency "process-group"

	spec.add_development_dependency "bundler", "~> 1.15"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end
