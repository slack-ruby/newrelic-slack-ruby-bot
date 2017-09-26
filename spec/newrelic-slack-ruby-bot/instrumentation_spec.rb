require 'spec_helper'

describe NewRelic::Agent::Instrumentation do
  let(:client) { SlackRubyBot::Client.new }
  subject do
    SlackRubyBot::Server.new
  end
  it 'perform_action_with_newrelic_trace' do
    expect(subject)
      .to receive(:perform_action_with_newrelic_trace)
      .with(hash_including(name: 'message'))
      .and_yield

    subject.message(client, Hashie::Mash.new(message: 'message', text: 'hi'))
  end
end
