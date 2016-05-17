# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soar_logstash_auditor/version'

Gem::Specification.new do |spec|
  spec.name          = "soar_logstash_auditor"
  spec.version       = LogstashAuditor::VERSION
  spec.authors       = ["Barney de Villiers"]
  spec.email         = ["barney.de.villiers@hetzner.co.za"]

  spec.summary       = %q{Logstash implementation of SOAR architecture auditing}
  spec.description   = %q{Logstash implementation of SOAR architecture auditing allowing easy publishing of events to a centralized logstash collection engine}
  spec.homepage      = "https://github.hetzner.co.za/hetznerZA/soar_logstash_auditor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "elasticsearch"
  spec.add_development_dependency "faraday"
  spec.add_development_dependency "hashie"

  spec.add_dependency 'rubysl-securerandom', "~> 2"

end