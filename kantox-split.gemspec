# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kantox/split/version'

Gem::Specification.new do |spec|
  spec.name          = 'kantox-split'
  spec.version       = Kantox::Split::VERSION
  spec.authors       = ['Kantox LTD']
  spec.email         = ['aleksei.matiushkin@kantox.com']

  spec.summary       = 'Easy split ActiveRecord’s CUD operations to write to separate data source.'
  spec.description   = 'This gem is extremely useful while in process of migration to another data source.'
  spec.homepage      = 'http://kantox.com'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(/^(test|spec|features)\//) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(/^exe\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
#    spec.metadata['allowed_push_host'] = "TODO: FURY"
  end

  spec.add_dependency 'rgl', '~> 0.5'
  spec.add_dependency 'kungfuig', '~> 0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_development_dependency 'rspec', '~> 2.12'
  spec.add_development_dependency 'cucumber', '~> 1.3'
  spec.add_development_dependency 'yard', '~> 0'

end
