# -*- encoding: utf-8 -*-
require File.expand_path('../lib/datastore-backend/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thorben Schröder"]
  gem.email         = ["info@thorbenschroeder.de"]
  gem.description   = %q{A backend to store and retrieve data for entities.}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/kntl/datastore-backend/"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "datastore-backend"
  gem.require_paths = ["lib"]
  gem.version       = Datastore::Backend::VERSION

  gem.add_dependency 'grape', '~> 0.4.0'
  gem.add_dependency 'mongoid', '~> 3.1.2'
  gem.add_dependency 'rack-jsonp-middleware', '0.0.5'
  gem.add_dependency 'json', '~> 1.7.7'
  gem.add_dependency 'uuid'
  gem.add_dependency 'auth-client', ">= 0.0.17"
  gem.add_dependency 'ping-middleware', '~> 0.0.2'
  gem.add_dependency 'grape_newrelic', '~> 0.0.3'
  gem.add_dependency 'cache-client', '~> 0.0.4'
  gem.add_dependency 'cache-backend-iron-cache', '~> 0.0.4'
end
