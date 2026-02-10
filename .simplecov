# frozen_string_literal: true

require 'simplecov'
require 'simplecov-json'

SimpleCov.start do
  add_filter 'spec'
  add_filter 'vendor'

  if ENV['CI']
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::HTMLFormatter,
                                                         SimpleCov::Formatter::JSONFormatter
                                                       ])
  end
end
