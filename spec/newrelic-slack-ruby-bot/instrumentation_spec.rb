require 'spec_helper'

describe NewRelic::Agent::Instrumentation do
  subject { SlackRubyBot::Hooks::Message.new }
  let(:client) { SlackRubyBot::Client.new }

  it 'perform_action_with_newrelic_trace' do
    expect(subject)
      .to receive(:perform_action_with_newrelic_trace)
      .with(hash_including(name: 'call', category: 'OtherTransaction/Slack'))
      .and_yield

    subject.call(client, Hashie::Mash.new(message: 'message', text: 'hi'))
  end
end
