# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'newrelic-slack-ruby-bot'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.before do
    DependencyDetection.detect!
  end
end
