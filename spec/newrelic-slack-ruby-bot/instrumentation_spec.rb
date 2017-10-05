require 'spec_helper'

describe NewRelic::Agent::Instrumentation do
  subject { SlackRubyBot::Hooks::Message.new }
  let(:client) { SlackRubyBot::Client.new }

  it 'perform_action_with_newrelic_trace' do
    expect(subject)
      .to receive(:perform_action_with_newrelic_trace)
      .with(hash_including(name: 'call', category: 'OtherTransaction/Slack'))
      .and_yield

    subject.call(client, Slack::Messages::Message.new(message: 'message',
                                                      text: 'hi',
                                                      team: 'TEAM',
                                                      channel: 'CHANNEL',
                                                      user: 'USER'))
  end

  it 'adds team, channel, and user attributes' do
    expect(::NewRelic::Agent)
      .to receive(:add_custom_attributes)
      .with(hash_including(team: 'TEAM', channel: 'CHANNEL', user: 'USER'))

    subject.call(client, Slack::Messages::Message.new(message: 'message',
                                                      text: 'hi',
                                                      team: 'TEAM',
                                                      channel: 'CHANNEL',
                                                      user: 'USER'))
  end
end
