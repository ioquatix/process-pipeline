
require_relative "lib/process/pipeline/version"

Gem::Specification.new do |spec|
	spec.name = "process-pipeline"
	spec.version = Process::Pipeline::VERSION
	
	spec.summary = "Execute composable shell-like pipelines."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/ioquatix/process-pipeline"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)

	spec.required_ruby_version = ">= 2.5"
	
	spec.add_dependency "process-group"
	
	spec.add_development_dependency "bake-bundler"
	spec.add_development_dependency "bake-modernize"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.0"
end
