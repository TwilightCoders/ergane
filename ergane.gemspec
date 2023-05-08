require_relative 'lib/ergane/version'

Gem::Specification.new do |spec|
  spec.name        = 'ergane'
  spec.version     = Ergane::VERSION
  spec.authors     = ['Dale Stevens']
  spec.email       = ['dale@twilightcoders.net']
  spec.summary     = 'Ergane — The patron goddess of craftsmen and artisans'

  spec.description = <<~STR
    Library for creating lightweight, yet powerful CLI tools in Ruby.
    Emphasis and priority on load speed and flexibility.
  STR

  spec.homepage    = 'https://github.com/TwilightCoders/ergane'
  spec.license     = 'MIT'

  spec.files         = Dir['CHANGELOG.md', 'README.md', 'LICENSE', 'app/**/*', 'lib/**/*', 'bin/**/*']
  spec.bindir        = 'bin'
  spec.executables   = ['ergane']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  ########################################
  ### Run Dependencies ###################
  ########################################
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'colorize'
  spec.add_runtime_dependency 'terminal-notifier'
  spec.add_runtime_dependency 'notifier'
  spec.add_runtime_dependency 'pry-byebug'

  ########################################
  ### Dev Dependencies ###################
  ########################################
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'

  # spec.add_development_dependency 'rubocop',             '~> 0.80'
  # spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  # spec.add_development_dependency 'rubocop-rspec',       '~> 1.38'
end
