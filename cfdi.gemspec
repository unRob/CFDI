# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfdi.rb'

Gem::Specification.new do |gem|
  gem.name          = "CFDI"
  gem.version       = CFDI::VERSION
  gem.authors       = ["Roberto Hidalgo"]
  gem.email         = ["un@rob.mx"]
  gem.description   = "Comprobantes fiscales digitales por internet"
  gem.summary       = "Digitales!! por Internet!!"
  gem.homepage      = "https://github.com/unRob/cfdi"
  gem.licenses      = ['WTFPL', 'GPLv2']
  gem.has_rdoc      = true

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  
  gem.add_runtime_dependency 'nokogiri'
  
end