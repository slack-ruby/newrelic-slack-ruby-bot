$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'newrelic-slack-ruby-bot/version'

Gem::Specification.new do |s|
  s.name = 'newrelic-slack-ruby-bot'
  s.version = NewRelic::Agent::Instrumentation::SlackRubyBot::VERSION
  s.authors = ['Daniel Doubrovkine']
  s.email = 'dblock@dblock.org'
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = Dir['**/*']
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/slack-ruby/newrelic-slack-ruby-bot'
  s.licenses = ['MIT']
  s.summary = 'NewRelic instrumentation for slack-ruby-bot.'
  s.add_dependency 'newrelic_rpm'
  s.add_dependency 'slack-ruby-bot', '>= 0.8.0'
end
