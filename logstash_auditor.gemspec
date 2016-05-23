# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logstash_auditor/version'

Gem::Specification.new do |spec|
  spec.name          = "logstash_auditor"
  spec.version       = LogstashAuditor::VERSION
  spec.authors       = ["Barney de Villiers"]
  spec.email         = ["barney.de.villiers@hetzner.co.za"]

  spec.summary       = %q{Logstash implementation of SOAR architecture auditing}
  spec.description   = %q{Logstash implementation of SOAR architecture auditing allowing easy publishing of events to a centralized logstash collection engine}
  spec.homepage      = "https://github.hetzner.co.za/hetznerZA/logstash_auditor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug", "~> 9"
  spec.add_development_dependency "elasticsearch", "~> 1"

  spec.add_dependency "http", "~> 2"
  spec.add_dependency "soar_auditor_api", "~> 0.0"

end
