# frozen_string_literal: true

require_relative 'lib/ergane/version'

Gem::Specification.new do |spec|
  spec.name          = 'ergane'
  spec.version       = Ergane::VERSION
  spec.authors       = ['Dale Stevens']
  spec.email         = ['dale@twilightcoders.net']

  spec.summary       = 'Ergane — a CLI framework forged for mortals'
  spec.description   = <<~DESC
    A lightweight, powerful CLI framework for Ruby. Define commands using
    class inheritance or block DSL — both produce the same command tree.
    An alternative to Thor with a cleaner, more Ruby-native design.
  DESC
  spec.homepage      = 'https://github.com/TwilightCoders/ergane'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files         = Dir['CHANGELOG.md', 'README.md', 'LICENSE', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'zeitwerk', '~> 2.6'
  spec.add_dependency 'colorize', '~> 1.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-json', '~> 0.2'
end
